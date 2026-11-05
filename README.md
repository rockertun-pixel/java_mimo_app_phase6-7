# Myanmar Code Learning App

Myanmar Unicode UI ပါဝင်သော Flutter micro-learning app ဖြစ်သည်။ Java lesson/quiz, sequential unlocking, XP, code viewer, sample output နှင့် light/dark/system theme တို့ပါဝင်ပြီး Phase 6 dashboard နှင့် Phase 7 energy/daily streak ကို ထည့်သွင်းထားသည်။

## Quick start

```bash
flutter pub get
flutter run -d chrome
```

အသေးစိတ် Burmese run/test လမ်းညွှန်ကို [RUN_TEST_GUIDE_MY.md](RUN_TEST_GUIDE_MY.md) တွင်ကြည့်ပါ။ Phase များကို [PHASE_6_README_MY.md](PHASE_6_README_MY.md) နှင့် [PHASE_7_README_MY.md](PHASE_7_README_MY.md) တွင်ဖတ်နိုင်သည်။

## Validation

```bash
flutter analyze
flutter test
```

## Architecture

Feature-based presentation folders နှင့် သီးခြား progress application service, Riverpod state controller, repository, versioned SharedPreferences persistence ကိုသုံးထားသည်။ ရှေး `user_progress` storage ကို `user_progress_v2` သို့ အလိုအလျောက် migrate လုပ်သည်။ Energy သည် ၅ ခုအထိရှိပြီး ၃၀ မိနစ်လျှင် ၁ ခု အလိုအလျောက်ပြန်ဖြည့်သည်။
