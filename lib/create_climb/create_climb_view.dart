import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';

import 'create_climb_bloc.dart';
import 'create_climb_state.dart';

class CreateClimbScreen extends StatefulWidget {
  CreateClimbScreen(
      {Key key,
      @required this.climb,
      @required this.location,
      @required this.categories,
      @required this.isEdit})
      : super(key: key);

  final Climb climb;
  final Location location;
  final List<String> categories;
  final bool isEdit;

  @override
  State<StatefulWidget> createState() => _CreateClimbState();
}

class _CreateClimbState extends State<CreateClimbScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateClimbBloc>(
      create: (context) => CreateClimbBloc(widget.climb, widget.location.grades),
      child: CreateClimbWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class CreateClimbWidget extends StatelessWidget {
  const CreateClimbWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final CreateClimbScreen widget;
  final _CreateClimbState widgetState;

  @override
  Widget build(BuildContext context) {
    String editTitleText =
        (widget.climb.displayName == "") ? "Edit climb" : "Edit ${widget.climb.displayName}";
    return Scaffold(
      appBar: AppBar(
          title: Text((widget.isEdit) ? editTitleText : "Create a climb"),
          actions: _buildActions(context)),
      body: _buildBody(context),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      (widget.isEdit)
          ? IconButton(
              icon: Icon(Icons.archive), onPressed: () => _showArchiveClimbDialog(context, this))
          : Container(),
      (widget.isEdit)
          ? IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () => _showDeleteClimbDialog(context, this))
          : Container()
    ];
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<CreateClimbBloc>(context),
        builder: (context, CreateClimbState state) {
          if (state.loading) {
            return Center(child: CircularProgressIndicator(strokeWidth: 4.0));
          } else {
            return Center(
              child: _showForm(state, context),
            );
          }
        });
  }

  Widget _showForm(CreateClimbState state, BuildContext context) {
    return Container(
        padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
        child: Form(
          key: state.formKey,
          child: Column(
            children: <Widget>[
              _showDisplayNameInput(state, context),
              _showImageInput(state, context),
              _showDropdowns(state, context),
              _showCategorySelection(state, context),
              _showSubmitButton(state, context)
            ],
          ),
        ));
  }

  Widget _showDisplayNameInput(CreateClimbState state, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        autofocus: false,
        style: Theme.of(context).accentTextTheme.subtitle2,
        initialValue: state.displayName,
        decoration: InputDecoration(
            labelText: 'Climb name (Optional)',
            filled: true,
            fillColor: Theme.of(context).cardColor,
            prefixIcon: Icon(
              Icons.text_fields,
            )),
        onSaved: (value) => state.displayName = value.trim(),
      ),
    );
  }

  Widget _showImageInput(CreateClimbState state, BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
        child: Column(
          children: <Widget>[
            _showImage(state, context),
            _showImageButtonBar(state, context),
          ],
        ));
  }

  Widget _showImage(CreateClimbState state, BuildContext context) {
    Widget content;
    if (state.deleteImage || (state.imageFile == null && state.imagePath == "")) {
      content = Container(
          decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
              color: Theme.of(context).cardColor),
          child: Center(
              child: Text(
            "Add an image to this climb (optional)",
            style: Theme.of(context).accentTextTheme.subtitle2,
            textAlign: TextAlign.center,
          )));
    } else if (state.imageFile != null) {
      content = Image.file(state.imageFile);
    } else {
      content = Image.network(state.imagePath);
    }
    return SizedBox(
      height: 200.0,
      child: content,
    );
  }

  Widget _showImageButtonBar(CreateClimbState state, BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(UIConstants.CARD_BORDER_RADIUS))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: _showImagePickerButton(state, context, "CAMERA",
                  Icon(Icons.camera_alt, color: Colors.black, size: 22), ImageSource.camera),
            ),
            Expanded(
              child: _showImagePickerButton(state, context, "GALLERY",
                  Icon(Icons.image, color: Colors.black, size: 22), ImageSource.gallery),
            ),
            Expanded(
              child: _showImageRemoveButton(state, context),
            )
          ],
        ));
  }

  Widget _showImagePickerButton(CreateClimbState state, BuildContext context, String buttonText,
      Icon icon, ImageSource imageSource) {
    return FlatButton(
      child: Row(children: <Widget>[
        Padding(padding: EdgeInsets.only(right: UIConstants.SMALLER_PADDING / 2), child: icon),
        Text(buttonText, style: Theme.of(context).primaryTextTheme.button),
      ]),
      onPressed: () => _openPictureDialog(context, imageSource),
    );
  }

  void _openPictureDialog(BuildContext context, ImageSource imageSource) async {
    File image = await ImagePicker.pickImage(source: imageSource);
    BlocProvider.of<CreateClimbBloc>(context).setImageFile(image);
  }

  Widget _showImageRemoveButton(CreateClimbState state, BuildContext context) {
    return FlatButton(
      child: Row(children: <Widget>[
        Padding(
            padding: EdgeInsets.only(right: UIConstants.SMALLER_PADDING / 2),
            child: Icon(Icons.delete_forever, color: Colors.black, size: 22)),
        Text("DELETE", style: Theme.of(context).primaryTextTheme.button),
      ]),
      onPressed: () => BlocProvider.of<CreateClimbBloc>(context).deleteImage(),
    );
  }

  Widget _showDropdowns(CreateClimbState state, BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
          child: Padding(
        padding: EdgeInsets.only(right: UIConstants.SMALLER_PADDING / 2),
        child: _showGradeDropdown(state, context),
      )),
      Expanded(
          child: Padding(
        padding: EdgeInsets.only(left: UIConstants.SMALLER_PADDING / 2),
        child: _showSectionDropdown(state, context),
      ))
    ]);
  }

  Widget _showGradeDropdown(CreateClimbState state, BuildContext context) {
    return DropdownButtonFormField<String>(
        decoration:
            InputDecoration(isDense: true, filled: true, fillColor: Theme.of(context).cardColor),
        style: Theme.of(context).accentTextTheme.subtitle2,
        items: _createDropdownItems(state.grades),
        value: state.grade,
        hint: Text("Grade"),
        isExpanded: true,
        validator: (String value) {
          if (value == null) {
            return 'A grade must be selected';
          }
          return null;
        },
        onChanged: (value) => BlocProvider.of<CreateClimbBloc>(context).selectGrade(value));
  }

  Widget _showSectionDropdown(CreateClimbState state, BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration:
          InputDecoration(isDense: true, filled: true, fillColor: Theme.of(context).cardColor),
      style: Theme.of(context).accentTextTheme.subtitle2,
      disabledHint: Text("No sections"),
      iconDisabledColor: Colors.grey,
      items: _createDropdownItems(widget.location.sections),
      value: state.section,
      hint: Text("Section"),
      isExpanded: true,
      validator: (String value) {
        if (widget.location.sections.isNotEmpty) {
          if (value == null) {
            return 'A section must be selected';
          }
        }
        return null;
      },
      onChanged: (value) => BlocProvider.of<CreateClimbBloc>(context).selectSection(value),
    );
  }

  List<DropdownMenuItem> _createDropdownItems(List<String> items) {
    if (items.isNotEmpty) {
      return items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList();
    } else {
      // null disables the dropdown
      return null;
    }
  }

  Widget _showCategorySelection(CreateClimbState state, BuildContext context) {
    List<Widget> itemChips = List<Widget>();
    widget.categories.forEach((item) {
      itemChips.add(_buildItemChip(state, context, item));
    });
    return Expanded(
        child: Padding(
            padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
            child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.FIELD_BORDER_RADIUS))),
                child: (itemChips.isNotEmpty)
                    ? ListView(children: <Widget>[
                        Wrap(
                            alignment: WrapAlignment.center,
                            spacing: UIConstants.SMALLER_PADDING,
                            runSpacing: 0.0,
                            children: itemChips)
                      ])
                    : Center(
                        child: Container(
                            child: Text("You don't currently have any climb categories",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).accentTextTheme.subtitle2))))));
  }

  Widget _buildItemChip(CreateClimbState state, BuildContext context, String item) {
    return Container(
      child: InputChip(
        label: Text(item),
        selected: state.selectedCategories.contains(item),
        showCheckmark: true,
        checkmarkColor: Colors.black,
        selectedColor: Theme.of(context).accentColor,
        labelStyle: state.selectedCategories.contains(item)
            ? Theme.of(context).primaryTextTheme.subtitle2
            : Theme.of(context).accentTextTheme.subtitle2,
        onSelected: (selected) =>
            BlocProvider.of<CreateClimbBloc>(context).toggleCategory(selected, item),
      ),
    );
  }

  Widget _showSubmitButton(CreateClimbState state, BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
            child: SizedBox(
                width: double.infinity,
                child: FlatButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(UIConstants.BUTTON_BORDER_RADIUS)),
                  color: Theme.of(context).accentColor,
                  child: Text('SUBMIT', style: Theme.of(context).primaryTextTheme.button),
                  onPressed: () => BlocProvider.of<CreateClimbBloc>(context)
                      .validateAndSubmit(widget.isEdit, state, context, this),
                ))));
  }

  void _showDeleteClimbDialog(
    BuildContext upperContext,
    CreateClimbWidget view,
  ) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text("Are you sure you want to delete this climb?",
                  style: Theme.of(context).accentTextTheme.headline5),
              content: Text("There is no way to get it back",
                  style: Theme.of(context).accentTextTheme.bodyText2),
              actions: <Widget>[
                FlatButton(
                  child: Text("CANCEL", style: Theme.of(context).accentTextTheme.button),
                  onPressed: navigateToLocation,
                ),
                FlatButton(
                  child: Text("DELETE", style: Theme.of(context).accentTextTheme.button),
                  onPressed: () => BlocProvider.of<CreateClimbBloc>(upperContext)
                      .deleteClimb(upperContext, view, widget.location, widget.categories),
                )
              ]);
        });
  }

  void _showArchiveClimbDialog(BuildContext upperContext, CreateClimbWidget view) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text("Are you sure you want to archive this climb?",
                  style: Theme.of(context).accentTextTheme.headline5),
              content: Text(
                  "It will still appear in your log but will no longer appear for this location",
                  style: Theme.of(context).accentTextTheme.bodyText2),
              actions: <Widget>[
                FlatButton(
                  child: Text("CANCEL", style: Theme.of(context).accentTextTheme.button),
                  onPressed: navigateToLocation,
                ),
                FlatButton(
                  child: Text("ARCHIVE", style: Theme.of(context).accentTextTheme.button),
                  onPressed: () => BlocProvider.of<CreateClimbBloc>(upperContext)
                      .archiveClimb(upperContext, view, widget.location, widget.categories),
                )
              ]);
        });
  }

  void navigateToLocation() {
    NavigationHelper.navigateBackOne(widgetState.context);
  }

  void navigateToClimbAfterEdit(CreateClimbState state) {
    NavigationHelper.navigateBackOne(widgetState.context);
    // when editing, pop back to location then reload climb
    if (widget.isEdit) {
      NavigationHelper.navigateBackOne(widgetState.context);
    }
    Climb climb = Climb(
        widget.climb.id,
        state.displayName,
        state.imagePath,
        state.imageUri,
        widget.climb.locationId,
        state.grade,
        widget.climb.gradeSet,
        state.section,
        widget.climb.archived,
        state.selectedCategories,
        widget.climb.attempts);
    NavigationHelper.navigateToClimb(widgetState.context, climb, widget.location, widget.categories,
        addToBackStack: true);
  }
}
