import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
      ),
      body: _buildBody(context),
      backgroundColor: Theme.of(context).backgroundColor,
    );
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
        padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
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
    if (state.deleteImage || (state.imageFile == null && state.imageUrl == "")) {
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
      content = Material(
          borderRadius: BorderRadius.all(Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
          child: Hero(
              tag: "climbImageHero",
              child: Container(
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
                    image: DecorationImage(
                      image: Image
                          .file(state.imageFile)
                          .image,
                      fit: BoxFit.cover,
                    )),
              )));
    } else {
      content = Material(
          borderRadius: BorderRadius.all(Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
          child: Hero(
              tag: "climbImageHero",
              child: CachedNetworkImage(
                imageUrl: state.imageUrl,
                imageBuilder: (context, imageProvider) =>
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )),
                    ),
                placeholder: (context, url) =>
                    SizedBox(
                        width: 60,
                        height: 60,
                        child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 4.0,
                            ))),
                errorWidget: (context, url, error) => Icon(Icons.error),
              )));
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
        child: _showSectionDropdown(state, context),
      )),
      Expanded(
          child: Padding(
        padding: EdgeInsets.only(left: UIConstants.SMALLER_PADDING / 2),
        child: _showGradeDropdown(state, context),
      ))
    ]);
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

  void navigateToLocation() {
    NavigationHelper.navigateBackOne(widgetState.context);
  }

  void navigateToClimb(CreateClimbState state) {
    NavigationHelper.navigateBackOne(widgetState.context);
    // when editing, pop back to location then reload climb
    if (widget.isEdit) {
      NavigationHelper.navigateBackOne(widgetState.context);
    }
    Climb climb = Climb(
        widget.climb.id,
        state.displayName,
        state.imageUrl,
        state.imageUri,
        widget.climb.locationId,
        state.grade,
        widget.climb.gradeSet,
        state.section,
        widget.climb.archived,
        widget.climb.sent,
        widget.climb.repeated,
        state.selectedCategories,
        widget.climb.attempts);
    NavigationHelper.navigateToClimb(widgetState.context, climb, widget.location, widget.categories,
        addToBackStack: true);
  }
}
