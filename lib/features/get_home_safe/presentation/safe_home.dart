import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/features/get_home_safe/data/get_home_safe_service.dart';
import 'package:metjou/features/get_home_safe/presentation/widgets/get_home_safe_sheet.dart';

/// Home card for Get home safe: shows the running schedule and opens the
/// panel to start or stop it.
class SafeHome extends StatefulWidget {
  const SafeHome({super.key});

  @override
  State<SafeHome> createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  GetHomeSafeState? current;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final state = await GetHomeSafeService.load();
    if (mounted) setState(() => current = state);
  }

  Future<void> _openSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => GetHomeSafeSheet(current: current),
    );
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: InkWell(
        onTap: _openSheet,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ListTile(
                        title: Text(context.l10n.getHomeSafe),
                        subtitle: Text(
                          current == null
                              ? context.l10n.getHomeSafeSubtitle
                              : describeSchedule(context, current!.schedule),
                        ),
                      ),
                      Visibility(
                        visible: current != null,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            children: [
                              SpinKitDoubleBounce(color: Colors.red, size: 15),
                              SizedBox(width: 15),
                              Text(
                                context.l10n.getHomeSafeActive,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset("assets/route.webp", height: 140),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
