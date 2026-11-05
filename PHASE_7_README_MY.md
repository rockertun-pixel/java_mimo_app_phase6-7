# Phase 7 — Energy နှင့် Daily Streak

## Energy စည်းမျဉ်းများ

Energy အများဆုံး ၅ ခုဖြစ်သည်။ Quiz မေးခွန်းများ load ပြီး စတင်နိုင်ချိန်တွင် energy ၁ ခုသာ လျော့သည်။ Quiz data မရှိခြင်း သို့မဟုတ် load မအောင်မြင်ခြင်းကြောင့် Quiz မစနိုင်ပါက energy မလျော့ပါ။ Energy မလုံလောက်ပါက မေးခွန်းများမစဘဲ လက်ကျန် energy နှင့် ပြန်ဖြည့်နည်းကို ပြသသည်။

Energy ကို မိနစ် ၃၀ တိုင်း ၁ ခု အလိုအလျောက်ပြန်ဖြည့်ပြီး အများဆုံး ၅ ခုတွင် ကန့်သတ်ထားသည်။ App ပိတ်ထားချိန်အပါအဝင် ကုန်ဆုံးသည့်အချိန်ကို local timestamp ဖြင့်တွက်သည်။ Quiz ပြန်ဖြေခြင်းတစ်ကြိမ်စီတွင်လည်း စတင်ချိန်၌ energy ၁ ခု အသုံးပြုသည်။

## Daily streak စည်းမျဉ်းများ

Quiz ဖြေဆိုရုံဖြင့် streak မတက်ပါ။ Quiz အောင်မြင်ပြီး `သင်ခန်းစာပြီးမြောက်ကြောင်း သိမ်းမည်` ကိုနှိပ်သည့်အခါမှ update လုပ်သည်။ တစ်နေ့လျှင် ပထမဆုံး lesson completion သာ streak ကို တစ်ရက်တိုးစေပြီး၊ တစ်နေ့တည်းတွင် နောက်ထပ် lesson များပြီးပါက ထပ်မတိုးပါ။

မနေ့က lesson ပြီးထားလျှင် ယနေ့ completion မှာ streak ဆက်တိုးမည်။ တစ်ရက်ကျော်လွတ်သွားလျှင် completion အသစ်လုပ်ချိန်တွင် ၁ မှ ပြန်စသည်။ ယနေ့ lesson မပြီးသေးသော်လည်း မနေ့ကအထိ streak အလုပ်လုပ်နေပါက dashboard တွင် ဆက်လက်လုပ်ဆောင်နိုင်သေးကြောင်း ပြသည်။ တစ်ရက်ကျော်လွတ်သွားပါက dashboard တွင် streak ၀ ပြမည်။

## Storage နှင့် migration

XP၊ ပြီးမြောက်ပြီးသော lesson ID များ၊ energy timestamp နှင့် streak ရက်စွဲကို SharedPreferences ထဲတွင် JSON အဖြစ် သိမ်းသည်။ Storage key အသစ်မှာ `user_progress_v2` ဖြစ်သည်။ မူလ `user_progress` schema မှ XP နှင့် completed lesson များကို ထိန်းသိမ်း၍ migrate လုပ်ပြီး၊ မရှိသေးသော energy ကို ၅ ခု၊ streak ကို ၀ ဖြင့် စတင်သည်။ Migration အောင်မြင်ပြီးမှ legacy key ကို ဖယ်ရှားသည်။

`lib/features/progress/application/progress_service.dart` သည် business rules များကို ကိုင်တွယ်ပြီး `lib/data/repositories/progress_repository.dart` သည် storage/migration ကို ကိုင်တွယ်သည်။ State ပြောင်းလဲမှုများကို notifier တွင် အစဉ်လိုက်လုပ်ဆောင်စေသည်။

## စမ်းသပ်နည်း

1. Home တွင် energy ၅ ခုရှိကြောင်း စစ်ပါ။
2. Lesson 1 ကိုဖွင့်၍ Quiz စပါ။ Quiz မျက်နှာပြင် စတင်ပြီးနောက် Home သို့ပြန်ကြည့်ရာ energy ၄ ခုဖြစ်ကြောင်း စစ်ပါ။
3. Quiz ကို အကြိမ်များစွာ စတင်၍ energy ၀ ဖြစ်အောင်လုပ်ပါ။ နောက်တစ်ကြိမ် Quiz စသောအခါ insufficient-energy screen ပေါ်ပြီး မေးခွန်းမစကြောင်း စစ်ပါ။
4. Unit test က မိနစ် ၃၀ ပြည့်သည့်အခါ energy ၁ ခု ပြန်တက်ခြင်းနှင့် အများဆုံး ၅ ခုဖြစ်ခြင်းကို စစ်သည်။ လက်တွေ့တွင် မိနစ် ၃၀ စောင့်ရန်မလိုပါ။
5. တစ်နေ့တည်းတွင် lesson နှစ်ခု ပြီးမြောက်စေပြီး streak တစ်ရက်သာတိုးကြောင်း စစ်ပါ။ နောက်တစ်နေ့တွင် lesson ပြီးပါက တစ်ရက်ထပ်တိုးကြောင်း စစ်ပါ။
6. App ကိုပြန်ဖွင့်၍ XP၊ completion၊ energy၊ streak တို့ မပျောက်ကြောင်း စစ်ပါ။
7. Migration unit test က legacy `user_progress` data ကို v2 key သို့ ပြောင်းရွှေ့ကြောင်း စစ်သည်။
