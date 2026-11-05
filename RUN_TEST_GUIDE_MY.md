# Run / Test Guide — Myanmar Code Learning App

ဤ project သည် Flutter 3.22 နှင့်အထက်၊ Dart 3.4 နှင့်အထက်ကို အသုံးပြုသည်။ Java သင်ခန်းစာများကို asset JSON မှဖတ်ပြီး လက်ရှိ app တွင် Java code ကို compile/run မလုပ်ပါ။

## ၁။ လိုအပ်ချက်များ

- Flutter SDK 3.22 နှင့်အထက်။ Installation ကို `flutter doctor` ဖြင့်စစ်ပါ။
- Android အတွက် Android Studio နှင့် Android SDK လိုအပ်သည်။ Web အတွက် Chrome လိုအပ်သည်။
- Package များကို ပထမဆုံး `flutter pub get` လုပ်စဉ် download လုပ်မည်။

## ၂။ Project ကို run လုပ်ရန်

ZIP ကို extract လုပ်ပြီး `java_mimo_app` folder ထဲဝင်ပါ။ ထို့နောက် အောက်ပါ command များကို run လုပ်ပါ။

```bash
cd java_mimo_app
flutter doctor
flutter pub get
flutter run -d chrome
```

Android emulator သို့မဟုတ် ချိတ်ဆက်ထားသော device အတွက်:

```bash
flutter devices
flutter run -d <device-id>
```

Web browser တွင် progress သည် browser profile နှင့် app origin အလိုက် သီးခြားသိမ်းမည်။ Browser storage ကိုရှင်းလင်းပါက local progress ပျောက်နိုင်သည်။

## ၃။ Phase အလိုက် လက်တွေ့စမ်းသပ်ရန်

### Phase 1–5 — ရှိပြီးသား Java learning app ကို regression စစ်ရန်

1. Home မှ Courses → Java သို့သွားပါ။
2. Lesson 1 ကိုဖွင့်၍ Myanmar Unicode စာသား၊ Java code viewer နှင့် sample output ကိုစစ်ပါ။
3. Quiz တွင် မှန်/မှားအဖြေ၊ quiz result နှင့် ၇၀% pass rule ကိုစစ်ပါ။
4. Settings မှ Light / Dark / System ကိုပြောင်းပြီး app ကိုပြန်ဖွင့်ပါ။ ရွေးချယ်မှု မပျောက်ကြောင်းစစ်ပါ။
5. Lesson မပြီးသေးမီ နောက် lesson သည် lock ဖြစ်ကြောင်း၊ lesson ပြီးနောက် နောက်တစ်ခု unlock ဖြစ်ကြောင်းစစ်ပါ။

### Phase 6 — Home Dashboard

1. App အသစ်စတင်ချိန်တွင် XP 0၊ Level 1၊ lesson 0/16၊ energy 5/5 နှင့် streak 0 ကိုစစ်ပါ။
2. `ဆက်လက်လေ့လာရန်` ကိုနှိပ်၍ ပထမဆုံး မပြီးသေးသော lesson ဖွင့်ကြောင်းစစ်ပါ။
3. Lesson တစ်ခု အောင်မြင်စွာပြီးမြောက်ကြောင်း သိမ်းပြီးနောက် XP၊ completed count နှင့် course progress ပြောင်းကြောင်းစစ်ပါ။
4. XP 100 ရောက်သောအခါ Level 2 သို့ပြောင်းပြီး level progress အသစ်မှစကြောင်းစစ်ပါ။
5. Browser refresh သို့မဟုတ် app restart လုပ်ပြီး dashboard data မပျောက်ကြောင်းစစ်ပါ။

### Phase 7 — Energy နှင့် streak

1. Quiz စတင်တိုင်း energy ၁ ခုလျော့ကြောင်း စစ်ပါ။ Lesson detail ကိုဖွင့်ရုံဖြင့် energy မလျော့ပါ။
2. Energy ၀ ဖြစ်သွားသောအခါ နောက်ထပ် Quiz မစနိုင်ဘဲ insufficient-energy message ပေါ်ကြောင်းစစ်ပါ။
3. မိနစ် ၃၀ တိုင်း energy ၁ ခု ပြန်တက်ပြီး အများဆုံး ၅ ခုသာရှိကြောင်းစစ်ပါ။ အချိန်ကို မစောင့်လိုပါက unit test ကိုအသုံးပြုပါ။
4. Quiz အောင်မြင်သော်လည်း completion သိမ်းသည့်ခလုတ်ကို မနှိပ်လျှင် streak မတိုးကြောင်းစစ်ပါ။
5. တစ်နေ့တည်း lesson နှစ်ခု ပြီးမြောက်စေရာ streak တစ်ရက်သာတိုးရမည်။ နောက်တစ်နေ့ lesson ပြီးလျှင် ထပ်တိုးရမည်။ တစ်ရက်လွတ်သွားပြီးနောက် lesson ပြီးလျှင် streak ၁ မှပြန်စရမည်။
6. Browser storage/app data ကိုရှင်းလင်းပါက local progress reset ဖြစ်မည်။ မလိုအပ်ဘဲ clear မလုပ်ပါနှင့်။

## ၄။ Automated tests နှင့် static analysis

Test အားလုံးကို run ရန်:

```bash
flutter test
```

Progress rules တစ်ခုတည်းကို run ရန်:

```bash
flutter test test/features/progress/application/progress_service_test.dart
```

Local migration ကို run ရန်:

```bash
flutter test test/data/progress_repository_test.dart
```

Startup widget test ကို run ရန်:

```bash
flutter test test/widget_test.dart
```

Static analysis:

```bash
flutter analyze
```

## ၅။ Local data နှင့် migration

Browser DevTools → Application → Local Storage မှ app origin ၏ storage ကိုသာ ရှင်းလင်းနိုင်သည်။ အခြား website များ၏ storage ကို မထိခိုက်စေရန် သတိပြုပါ။

Migration ကို `flutter test test/data/progress_repository_test.dart` ဖြင့်စမ်းနိုင်သည်။ Test သည် ရှေး `user_progress` key ထဲမှ XP နှင့် completed lesson ID များကို ထိန်းသိမ်းပြီး `user_progress_v2` သို့ရွှေ့ခြင်း၊ legacy key ဖယ်ရှားခြင်းတို့ကို စစ်ဆေးသည်။ ရှေး data တွင် energy မရှိပါက ၅ ဖြင့်၊ streak မရှိပါက ၀ ဖြင့် စတင်သည်။

## ၆။ Folder structure

```text
lib/
  data/models/                     # Course, lesson, progress models
  data/repositories/               # Course, quiz, progress persistence boundary
  features/home/presentation/      # Dashboard
  features/courses/                # Course and lesson screens
  features/quiz/                   # Quiz UI and results
  features/progress/application/   # XP, streak, energy rules
  features/progress/providers/     # Riverpod progress controller
  app/theme/                       # Existing theme setting
```

UI → Riverpod controller → `ProgressService` → `ProgressRepository` → SharedPreferences ဟူသော အလွှာခွဲပုံကိုအသုံးပြုထားသည်။ Progress ကို versioned `user_progress_v2` key ဖြင့်သိမ်းပြီး ရှေး `user_progress` key ကို load လုပ်ချိန်တွင် migrate လုပ်သည်။ Quiz, lesson, code viewer, sample output နှင့် theme အပိုင်းများကို မလိုအပ်ဘဲ ပြန်မရေးထားပါ။
