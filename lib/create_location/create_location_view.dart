import 'dart:io';

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
  CreateLocationScreen({Key key, @required this.location, @required this.isEdit}) : super(key: key);

  final Location location;
  final bool isEdit;

  @override
  State<StatefulWidget> createState() => _CreateLocationState();
}

class _CreateLocationState extends State<CreateLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateLocationBloc>(
      create: (context) => CreateLocationBloc(widget.location, widget.isEdit),
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
    );
  }

  Widget _showForm(CreateLocationState state, BuildContext context) {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: state.formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showDisplayNameInput(state),
              _showImageInput(state, context),
              Row(children: <Widget>[
                Expanded(
                  child: _showGradesDropdown(state, context),
                ),
                Expanded(
                  child: _showGradeCreationButton(state, context),
                )
              ]),
              Center(child: _showSectionsText(state, context)),
              _showSectionCreator(state, context),
              _showSubmitButton(state, context)
            ],
          ),
        ));
  }

  Widget _showImageInput(CreateLocationState state, BuildContext context) {
    return Column(
      children: <Widget>[
        _showImage(state, context),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _showImagePickerButton(state, context, "Camera",
                Icon(Icons.camera_alt, color: Colors.white), ImageSource.camera),
            _showImagePickerButton(state, context, "Gallery",
                Icon(Icons.image, color: Colors.white), ImageSource.gallery),
            _showImageRemoveButton(state, context),
          ],
        )
      ],
    );
  }

  Widget _showImage(CreateLocationState state, BuildContext context) {
    Widget content;
    if (state.deleteImage || (state.imageFile == null && state.imagePath == "")) {
      content = Center(
        child: Text(
          "Add an image to this location",
          textAlign: TextAlign.center,
        ),
      );
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

  Widget _showImagePickerButton(CreateLocationState state, BuildContext context, String buttonText,
      Icon icon, ImageSource imageSource) {
    return new Padding(
        padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: UIConstants.STANDARD_ELEVATION,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(UIConstants.STANDARD_BORDER_RADIUS)),
            color: Colors.pink,
            child: Row(children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, UIConstants.SMALLER_PADDING, 0.0),
                  child: icon),
              Text(buttonText, style: new TextStyle(fontSize: 14.0, color: Colors.white)),
            ]),
            onPressed: () => _openPictureDialog(context, imageSource),
          ),
        ));
  }

  void _openPictureDialog(BuildContext context, ImageSource imageSource) async {
    File image = await ImagePicker.pickImage(source: imageSource);
    BlocProvider.of<CreateLocationBloc>(context).setImageFile(image);
  }

  Widget _showImageRemoveButton(CreateLocationState state, BuildContext context) {
    return new Padding(
        padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: UIConstants.STANDARD_ELEVATION,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(UIConstants.STANDARD_BORDER_RADIUS)),
            color: Colors.pink,
            child: Row(children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, UIConstants.SMALLER_PADDING, 0.0),
                  child: Icon(Icons.delete_forever, color: Colors.white)),
              Text("Delete", style: new TextStyle(fontSize: 14.0, color: Colors.white)),
            ]),
            onPressed: () => BlocProvider.of<CreateLocationBloc>(context).deleteImage(),
          ),
        ));
  }

  Widget _showDisplayNameInput(CreateLocationState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
          UIConstants.STANDARD_PADDING, UIConstants.STANDARD_PADDING),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        initialValue: state.displayName,
        decoration: new InputDecoration(
            hintText: 'Location name',
            icon: new Icon(
              Icons.text_fields,
              color: Colors.grey,
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

  Widget _showGradesDropdown(CreateLocationState state, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
            UIConstants.STANDARD_PADDING, UIConstants.STANDARD_PADDING),
        child: new DropdownButtonFormField<String>(
          items: _createDropdownItems(state),
          value: state.gradeSet,
          hint: Text("Grades"),
          isExpanded: true,
          validator: (String value) {
            if (value == null) {
              return 'A grade set must be selected';
            }
            return null;
          },
          onChanged: (value) => BlocProvider.of<CreateLocationBloc>(context).selectGrade(value),
        ));
  }

  List<DropdownMenuItem> _createDropdownItems(CreateLocationState state) {
    return state.grades.map((String value) {
      return new DropdownMenuItem<String>(
        value: value,
        child: new Text(value),
      );
    }).toList();
  }

  Widget _showGradeCreationButton(CreateLocationState state, BuildContext context) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
            UIConstants.STANDARD_PADDING, UIConstants.STANDARD_PADDING),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: UIConstants.STANDARD_ELEVATION,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(UIConstants.STANDARD_BORDER_RADIUS)),
            color: Colors.pink,
            child: new Text('Create a grade set',
                style: new TextStyle(fontSize: 14.0, color: Colors.white)),
            onPressed: () => _showCreateGradeSetDialog(context),
          ),
        ));
  }

  _showCreateGradeSetDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(title: Text("Create a grade set"), children: <Widget>[
            CreateGradeSet(),
          ]);
        });
  }

  Widget _showSectionsText(CreateLocationState state, BuildContext context) {
    return StreamBuilder(
        stream: BlocProvider.of<CreateLocationBloc>(context).sectionsStream.stream,
        initialData: (state.sections == null) ? <String>[] : state.sections,
        builder: (BuildContext context, snapshot) {
          return Padding(
              padding: EdgeInsets.fromLTRB(
                  UIConstants.STANDARD_PADDING, 0.0, UIConstants.STANDARD_PADDING, 0.0),
              child: Text(
                (snapshot.data.isEmpty) ? "No sections added" : snapshot.data.join(', '),
                style: TextStyle(
                    fontSize: 13.0, color: Colors.grey, height: 1.0, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ));
        });
  }

  Widget _showSectionCreator(CreateLocationState state, BuildContext context) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, UIConstants.SMALLER_PADDING,
            UIConstants.STANDARD_PADDING, UIConstants.STANDARD_PADDING),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: UIConstants.STANDARD_ELEVATION,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(UIConstants.STANDARD_BORDER_RADIUS)),
            color: Colors.pink,
            child: new Text('Create sections (optional)',
                style: new TextStyle(fontSize: UIConstants.BIGGER_FONT_SIZE, color: Colors.white)),
            onPressed: () => _showAddSectionsDialog(state, context),
          ),
        ));
  }

  void _showAddSectionsDialog(CreateLocationState state, BuildContext upperContext) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return SimpleDialog(title: Text("Edit this location's sections"), children: <Widget>[
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
    return new Padding(
        padding: EdgeInsets.fromLTRB(
            UIConstants.STANDARD_PADDING, 0.0, UIConstants.STANDARD_PADDING, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: UIConstants.STANDARD_ELEVATION,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(UIConstants.STANDARD_BORDER_RADIUS)),
            color: Colors.pink,
            child: new Text('Submit',
                style: new TextStyle(fontSize: UIConstants.BIGGER_FONT_SIZE, color: Colors.white)),
            onPressed: () => BlocProvider.of<CreateLocationBloc>(context)
                .validateAndSubmit(state, context, this),
          ),
        ));
  }

  void _showDeleteLocationDialog(BuildContext upperContext, CreateLocationWidget view) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Are you sure you want to delete this location?"),
              content: Text("There is no way to get it (or any of its climbs) back"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () => navigateBackOne,
                ),
                FlatButton(
                  child: Text("Delete"),
                  onPressed: () => BlocProvider.of<CreateLocationBloc>(upperContext)
                      .deleteLocation(upperContext, view),
                )
              ]);
        });
  }

  void navigateBackOne() {
    NavigationHelper.navigateBackOne(widgetState.context);
  }

  void navigateToLocationAfterEdit(CreateLocationState state) {
    NavigationHelper.navigateBackOne(widgetState.context);
    // when editing, pop back to main then reload location
    if (widget.isEdit) {
      NavigationHelper.navigateBackOne(widgetState.context);
    }
    SelectedLocation selectedLocation = SelectedLocation(
        widget.location.id, state.displayName, state.imagePath, state.imageUri, state.gradeSet);
    NavigationHelper.navigateToLocation(
        widgetState.context, selectedLocation, widget.location.categories,
        addToBackStack: true);
  }
}
