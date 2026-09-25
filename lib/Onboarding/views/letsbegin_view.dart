import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metjou/Onboarding/views/onboarding_page.dart';

class Letsbegin extends StatefulWidget {
  final AnimationController animationController;

  const Letsbegin({super.key, required this.animationController});

  @override
  _LetsbeginState createState() => _LetsbeginState();

}

class _LetsbeginState extends State<Letsbegin> {
  final List locale =[
    {'name':'Arabic','locale': Locale('ar','AR')},
    {'name':'Français','locale': Locale('fr','FR')},
    {'name':'English','locale': Locale('en','US')},
    {'name':'Russian','locale': Locale('ru','RU')},
    {'name':'Italien','locale': Locale('it','IT')},
    {'name':'Deutsch','locale': Locale('de','DE')},
  ];
  updateLanguage(Locale locale){
    Get.back();
    Get.updateLocale(locale);
  }

  buildLanguageDialog(BuildContext context){
    showDialog(context: context,
        builder: (builder){
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            title: Text('choislang'.tr,
                style: TextStyle(fontSize: 22,)),
            backgroundColor: Color(0xfff5ebe2),
            contentPadding: EdgeInsets.only(top: 16.0, bottom: 16.0,left: 16.0,right: 16.0),
            content: Container(
              width: double.maxFinite,
              child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context,index){
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(child: Text(locale[index]['name']),
                        onTap: (){
                        updateLanguage(locale[index]['locale']);
                      },),
                    );
                  }, separatorBuilder: (context,index){
                return Divider(
                  color: Color(0xff000000),
                );
              }, itemCount: locale.length
              ),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final _introductionanimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(0.0, -1.0))
            .animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(
        0.0,
        0.2,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    return SlideTransition(
      position: _introductionanimation,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/onboarding/introduction_image.webp',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "MetJou",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'onbletbegdesc'.tr,
                style: TextStyle(fontSize: 16, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: onboardingPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  onPressed: () => widget.animationController.animateTo(0.2),
                  child: Text('onbletbegwelc'.tr, style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: onboardingPrimary,
                    side: const BorderSide(color: onboardingPrimary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  onPressed: () => buildLanguageDialog(context),
                  icon: const Icon(Icons.language),
                  label: Text('changelang'.tr, style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
