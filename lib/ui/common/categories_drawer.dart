import 'package:flutter/material.dart';

import '../../src/blocs/bloc.dart';
import '../../src/blocs/provider.dart';
import 'index.dart';

class CategoriesDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Todo-List Demo with moor',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: Colors.white),
            ),
            decoration: BoxDecoration(color: Colors.orange),
          ),
          Flexible(
            child: StreamBuilder<List<CategoryWithActiveInfo>>(
              stream: BlocProvider.provideBloc(context).categories,
              builder: (context, snapshot) {
                final categories = snapshot.data ?? <CategoryWithActiveInfo>[];

                return ListView.builder(
                  itemBuilder: (context, index) {
                    return _CategoryDrawerEntry(entry: categories[index]);
                  },
                  itemCount: categories.length,
                );
              },
            ),
          ),
          Spacer(),
          Row(
            children: <Widget>[
              FlatButton(
                child: const Text('Add category'),
                textColor: Theme.of(context).accentColor,
                onPressed: () {
                  showDialog(
                      context: context, builder: (_) => AddCategoryDialog());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryDrawerEntry extends StatelessWidget {
  final CategoryWithActiveInfo entry;

  const _CategoryDrawerEntry({Key key, this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = entry.categoryWithCount.category;
    String title;
    if (category == null) {
      title = 'No category';
    } else {
      title = category.description ?? 'Unnamed';
    }

    final isActive = entry.isActive;
    final bloc = BlocProvider.provideBloc(context);

    final rowContent = [
      Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isActive ? Theme.of(context).accentColor : Colors.black,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('${entry.categoryWithCount?.count} entries'),
      ),
    ];

    // also show a delete button if the category can be deleted
    if (category != null) {
      rowContent.addAll([
        Spacer(),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Delete'),
                  content: Text('Really delete category $title?'),
                  actions: <Widget>[
                    FlatButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                    ),
                    FlatButton(
                      child: const Text('Delete'),
                      textColor: Colors.red,
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                  ],
                );
              },
            );

            if (confirmed == true) {
              // can be null when the dialog is dismissed
              bloc.deleteCategory(category);
            }
          },
        ),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Material(
        color: isActive
            ? Colors.orangeAccent.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            bloc.showCategory(entry.categoryWithCount.category);
            Navigator.pop(context); // close the navigation drawer
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: rowContent,
            ),
          ),
        ),
      ),
    );
  }
}
