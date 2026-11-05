# Phase 6 — Home Dashboard

## ထည့်သွင်းထားသော feature များ

- Total XP ကို user progress မှ တိုက်ရိုက်ပြသခြင်း။
- Level တွက်ချက်မှု — XP ၁၀၀ စီတိုင်း level တစ်ဆင့်တက်ပြီး လက်ရှိ level တိုးတက်မှု bar ကို ပြသခြင်း။
- Java သင်ခန်းစာပြီးမြောက်မှု အရေအတွက်နှင့် course progress bar။
- Continue learning ကို ပထမဆုံး မပြီးသေးသော Java lesson သို့ တိုက်ရိုက်ချိတ်ဆက်ခြင်း။
- Energy ၅ ခုကို heart ပုံစံဖြင့်ပြသခြင်း။
- နေ့စဉ် streak နှင့် ယနေ့ lesson ပြီး/မပြီး အခြေအနေပြသခြင်း။
- မျက်နှာပြင်အရွယ်အစားနှင့် light/dark/system theme ကိုလိုက်လျောညီထွေပြသခြင်း။

## အဓိက File များ

```text
lib/features/home/presentation/home_screen.dart
lib/data/models/user_progress_model.dart
lib/features/progress/providers/progress_provider.dart
```

## စမ်းသပ်နည်း

1. App ကို run ပြီး Home tab သို့သွားပါ။
2. စတင်အသုံးပြုသူအတွက် `0 XP`, `Level 1`, lesson progress နှင့် energy `5 / 5` ပေါ်ကြောင်း စစ်ပါ။
3. `ဆက်လက်လေ့လာရန်` ကိုနှိပ်ပြီး မပြီးသေးသော lesson ဖွင့်ကြောင်း စစ်ပါ။
4. Quiz ကို အောင်မြင်ပြီး lesson ပြီးမြောက်မှုသိမ်းပါ။ Home သို့ပြန်၍ XP၊ lesson count၊ progress bar ပြောင်းကြောင်း စစ်ပါ။
5. XP ၁၀၀ ရောက်ပါက level တိုးပြီး level bar အသစ်စကြောင်း စစ်ပါ။
6. App ကိုပိတ်/ပြန်ဖွင့်ပြီး dashboard တန်ဖိုးများ မပျောက်ကြောင်း စစ်ပါ။
