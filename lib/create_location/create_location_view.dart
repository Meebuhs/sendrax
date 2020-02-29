import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendrax/create_location/create_gradeset/create_gradeset_view.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/string_collection_input/string_collection_input_view.dart';
import 'package:sendrax/util/constants.dart';

import 'create_location_bloc.dart';
import 'create_location_state.dart';

class CreateLocationScreen extends StatefulWidget {
  CreateLocationScreen(
      {Key key, @required this.location, @required this.categories, @required this.isEdit})
      : super(key: key);

  final Location location;
  final List<String> categories;
  final bool isEdit;

  @override
  State<StatefulWidget> createState() => _CreateLocationState();
}

class _CreateLocationState extends State<CreateLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateLocationBloc>(
      create: (context) => CreateLocationBloc(widget.location, widget.categories, widget.isEdit),
      child: CreateLocationWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class CreateLocationWidget extends StatelessWidget {
  const CreateLocationWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final CreateLocationScreen widget;
  final _CreateLocationState widgetState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.isEdit) ? "Edit ${widget.location.displayName}" : "Create a location"),
        actions: <Widget>[
          (widget.isEdit)
              ? IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: () => _showDeleteLocationDialog(context, this),
                )
              : Container()
        ],
      ),
      body: BlocBuilder(
          bloc: BlocProvider.of<CreateLocationBloc>(context),
          builder: (context, CreateLocationState state) {
            if (state.loading) {
              return Center(child: CircularProgressIndicator(strokeWidth: 4.0));
            } else {
              return Center(
                child: ListView(
                  children: <Widget>[_showForm(state, context)],
                ),
              );
            }
          }),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget _showForm(CreateLocationState state, BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: state.formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showDisplayNameInput(state, context),
              _showImageInput(state, context),
              _buildGradeSetConfig(state, context),
              Column(
                children: <Widget>[
                  _showSectionsText(state, context),
                  _showSectionCreator(state, context),
                ],
              ),
              _showSubmitButton(state, context)
            ],
          ),
        ));
  }

  Widget _showDisplayNameInput(CreateLocationState state, BuildContext context) {
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
            labelText: 'Location name',
            filled: true,
            fillColor: Theme.of(context).cardColor,
            prefixIcon: Icon(
              Icons.text_fields,
            )),
        validator: (String value) {
          if (value.trim().isEmpty) {
            return 'Location must have a name';
          }
          return null;
        },
        onSaved: (value) => state.displayName = value.trim(),
      ),
    );
  }

  Widget _showImageInput(CreateLocationState state, BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
        child: Column(
          children: <Widget>[
            _showImage(state, context),
            _showImageButtonBar(state, context),
          ],
        ));
  }

  Widget _showImage(CreateLocationState state, BuildContext context) {
    Widget content;
    if (state.deleteImage || (state.imageFile == null && state.imageUrl == null)) {
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
          child: Hero(
              tag: "${widget.location.displayName}-image",
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
          child: Hero(
              tag: "${widget.location.displayName}-image",
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

  Widget _showImageButtonBar(CreateLocationState state, BuildContext context) {
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

  Widget _showImagePickerButton(CreateLocationState state, BuildContext context, String buttonText,
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
    BlocProvider.of<CreateLocationBloc>(context).setImageFile(image);
  }

  Widget _showImageRemoveButton(CreateLocationState state, BuildContext context) {
    return FlatButton(
      child: Row(children: <Widget>[
        Padding(
            padding: EdgeInsets.only(right: UIConstants.SMALLER_PADDING / 2),
            child: Icon(Icons.delete_forever, color: Colors.black, size: 22)),
        Text("DELETE", style: Theme.of(context).primaryTextTheme.button),
      ]),
      onPressed: () => BlocProvider.of<CreateLocationBloc>(context).deleteImage(),
    );
  }

  Widget _buildGradeSetConfig(CreateLocationState state, BuildContext context) {
    return (widget.isEdit)
        ? Container()
        : Padding(
            padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _showGradesDropdown(state, context),
                ),
                Expanded(
                  child: _showGradeCreationButton(state, context),
                )
              ],
            ),
          );
  }

  Widget _showGradesDropdown(CreateLocationState state, BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: UIConstants.SMALLER_PADDING / 2),
        child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    isDense: true, filled: true, fillColor: Theme.of(context).cardColor),
                style: Theme.of(context).accentTextTheme.subtitle2,
                items: _createDropdownItems(state),
                value: state.gradeSet,
                hint: Text("Grade set"),
                isExpanded: true,
                validator: (String value) {
                  if (value == null) {
                    return 'A grade set must be selected';
                  }
                  return null;
                },
                onChanged: (value) =>
                    BlocProvider.of<CreateLocationBloc>(context).selectGrade(value))));
  }

  List<DropdownMenuItem> _createDropdownItems(CreateLocationState state) {
    return state.gradeSets.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  Widget _showGradeCreationButton(CreateLocationState state, BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: UIConstants.SMALLER_PADDING),
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.BUTTON_BORDER_RADIUS)),
          color: Theme.of(context).accentColor,
          child: Text('CREATE GRADE SET', style: Theme.of(context).primaryTextTheme.button),
          onPressed: () => _showCreateGradeSetDialog(context),
        ));
  }

  _showCreateGradeSetDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text("Create a grade set", style: Theme.of(context).accentTextTheme.headline5),
              backgroundColor: Theme.of(context).cardColor,
              children: <Widget>[
                CreateGradeSet(),
              ]);
        });
  }

  Widget _showSectionsText(CreateLocationState state, BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(minHeight: 60, minWidth: double.infinity),
        child: Container(
            padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
                color: Theme.of(context).cardColor),
            child: StreamBuilder(
                stream: BlocProvider.of<CreateLocationBloc>(context).sectionsStream.stream,
                initialData: (state.sections == null) ? <String>[] : state.sections,
                builder: (BuildContext context, snapshot) {
                  return Center(
                      child: Text(
                    (snapshot.data.isEmpty)
                        ? "No sections added"
                        : "Sections: ${snapshot.data.join(', ')}",
                    style: Theme.of(context).accentTextTheme.subtitle2,
                    textAlign: TextAlign.center,
                  ));
                })));
  }

  Widget _showSectionCreator(CreateLocationState state, BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(UIConstants.BUTTON_BORDER_RADIUS))),
          color: Theme.of(context).accentColor,
          child: Text((widget.isEdit) ? "EDIT SECTIONS" : 'CREATE SECTIONS (optional)',
              style: Theme.of(context).primaryTextTheme.button),
          onPressed: () => _showAddSectionsDialog(state, context),
        ));
  }

  void _showAddSectionsDialog(CreateLocationState state, BuildContext upperContext) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text("Edit this location's sections",
                  style: Theme.of(context).accentTextTheme.headline5),
              backgroundColor: Theme.of(context).cardColor,
              children: <Widget>[
                StringCollectionInputScreen(
                    items: state.sections,
                    itemName: "Section",
                    upperContext: upperContext,
                    submitInput: _submitInput),
              ]);
        });
  }

  void _submitInput(List<String> itemList, BuildContext context) {
    BlocProvider.of<CreateLocationBloc>(context).sectionsStream.add(itemList);
  }

  Widget _showSubmitButton(CreateLocationState state, BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
        child: SizedBox(
            width: double.infinity,
            child: FlatButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.BUTTON_BORDER_RADIUS)),
              color: Theme.of(context).accentColor,
              child: Text('SUBMIT', style: Theme.of(context).primaryTextTheme.button),
              onPressed: () => BlocProvider.of<CreateLocationBloc>(context)
                  .validateAndSubmit(state, context, this),
            )));
  }

  void _showDeleteLocationDialog(BuildContext upperContext, CreateLocationWidget view) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Are you sure you want to delete this location?",
                  style: Theme.of(context).accentTextTheme.headline5),
              content: Text("There is no way to get it (or any of its climbs) back",
                  style: Theme.of(context).accentTextTheme.bodyText2),
              actions: <Widget>[
                FlatButton(
                  child: Text("CANCEL", style: Theme.of(context).accentTextTheme.button),
                  onPressed: () => navigateBackOne(),
                ),
                FlatButton(
                  child: Text("DELETE", style: Theme.of(context).accentTextTheme.button),
                  onPressed: () => BlocProvider.of<CreateLocationBloc>(upperContext)
                      .deleteLocation(upperContext, view),
                )
              ]);
        });
  }

  void navigateBackOne() {
    NavigationHelper.navigateBackOne(widgetState.context);
  }
}
