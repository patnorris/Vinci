import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  final logoutAction;

  const MenuDrawer({Key key, @required this.logoutAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Container(
      color: Colors.indigo[100],
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              children: [
                Container(
                  height: 100.0,
                  child: Image(
                    image: AssetImage('assets/images/Vinci_logo_version1.png'),
                  ),
                ),
                Container(
                  height: 10.0,
                ),
                Text(
                  'Vinci',
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.indigo[800],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text(
              'My Stream',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/stream');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'My Profile',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: Text(
              'My Topics',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/topics');
            },
          ),
          ListTile(
            leading: Icon(Icons.save_alt),
            title: Text(
              'My Saved Nuggets',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/saved');
            },
          ),
          ListTile(
            leading: Icon(Icons.create),
            title: Text(
              'Create Nugget',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/create');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(
              'Logout',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            onTap: () {
              logoutAction();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    ));
  }
}
