import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/widgets/glass.dart';
import 'package:metjou/features/get_home_safe/presentation/get_home_safe_viewmodel.dart';
import 'package:metjou/features/get_home_safe/presentation/widgets/get_home_safe_sheet.dart';

/// Home card for Get home safe: shows the running schedule and opens the
/// panel to start or stop it.
class SafeHome extends ConsumerWidget {
  const SafeHome({super.key});

  /// Tells the contacts you are home, and ends Get home safe and a
  /// running check-in timer in one tap.
  Future<void> _imHome(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final sent = await ref
        .read(getHomeSafeViewModelProvider.notifier)
        .imHome(l10n.smsHome);
    Fluttertoast.showToast(
      msg: sent == 0 ? l10n.noContactsFound : l10n.imHomeSent,
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const GetHomeSafeSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(getHomeSafeViewModelProvider).running;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: GlassPanel(
        onTap: () => _openSheet(context),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            children: [
              SizedBox(
                height: 150,
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
                                  : describeSchedule(context, current.schedule),
                            ),
                          ),
                          Visibility(
                            visible: current != null,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Row(
                                children: [
                                  SpinKitDoubleBounce(
                                    color: Theme.of(context).colorScheme.error,
                                    size: 15,
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    context.l10n.getHomeSafeActive,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _imHome(context, ref),
                    icon: const Icon(Icons.home_rounded),
                    label: Text(context.l10n.imHome),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
