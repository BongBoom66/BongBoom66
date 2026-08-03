# GridHedge_XAUUSD — MT5 Single-Order Trend EA (Exness Cent)

Expert Advisor សម្រាប់ MetaTrader 5 (MQL5) — **1 Order ក្នុងមួយពេល**, TP/SL ថេរ, តាម Trend៖

- ពេលគ្មាន Position បើក (Flat) តម្លៃទីផ្សារបច្ចុប្បន្នក្លាយជា **Base price**
- រង់ចាំតម្លៃធ្វើចលនាឆ្ងាយ `InpTriggerGapUSD` ($2 default) ពី Base ទិសណាមួយ
- ទិសណាមកដល់មុន បើក Order **មួយប៉ុណ្ណោះ** ភ្លាមៗ (Market order)៖ តម្លៃឡើងដល់ Base+Gap → **Buy**, តម្លៃចុះដល់ Base−Gap → **Sell**
- Order នោះមាន **TP/SL ដាក់ផ្ទាល់ពី Broker** (`InpTakeProfitUSD`=$0.5, `InpStopLossUSD`=$50 default) — Broker បិទ Order ដោយស្វ័យប្រវត្តិពេលដល់ណាមួយ មិនចាំបាច់ពឹងលើ EA/Terminal ដំណើរការជានិច្ចទេ
- ពេល Order បិទ (មិនថាដោយ TP ឬ SL) EA **រង់ចាំ Order បន្ទាប់ភ្លាមៗ** ដោយកំណត់ Base price ថ្មីត្រង់តម្លៃទីផ្សារបច្ចុប្បន្ន

## ឯកសារ

- `GridHedge_XAUUSD.mq5` — កូដ EA ពេញលេញ, compile ដោយ MetaEditor (F7) នៅក្នុង MT5

## របៀបប្រើ

1. ចម្លងឯកសារ `GridHedge_XAUUSD.mq5` ទៅក្នុងថត `MQL5/Experts/` នៃ MT5 terminal របស់អ្នក (File → Open Data Folder)
2. បើក MetaEditor ហើយ compile ឯកសារនេះ (F7)
3. បើក Chart នៃ Gold តាម symbol ពិតរបស់ broker Exness Cent របស់អ្នក (ជាធម្មតាមាន suffix ដូចជា `XAUUSDc` — ត្រូវប្រើ symbol ត្រឹមត្រូវនៃ Cent account, មិនមែន `XAUUSD` ធម្មតាទេ)
4. អូស EA ចូល Chart នោះ ហើយបើក "Algo Trading"

## Input Parameters

| Parameter | អត្ថន័យ | លំនាំដើម |
|---|---|---|
| `InpLotSize` | Lot size សម្រាប់ Order នីមួយៗ | 0.01 |
| `InpTriggerGapUSD` | ចម្ងាយពី Base price ដែលបង្កឲ្យចូល Order ($) | 2.0 |
| `InpTakeProfitUSD` | ចម្ងាយ Take Profit ពីតម្លៃចូល ($) | 0.5 |
| `InpStopLossUSD` | ចម្ងាយ Stop Loss ពីតម្លៃចូល ($) | 50.0 |
| `InpSlippagePoints` | Slippage អតិបរមាសម្រាប់ market order | 30 |
| `InpMagicNumber` | Magic number កំណត់អត្តសញ្ញាណ trade របស់ EA នេះ | 20260802 |

## ឧទាហរណ៍ដំណើរការ

Base = $4000, `InpTriggerGapUSD`=$2, `InpTakeProfitUSD`=$0.5, `InpStopLossUSD`=$50

- តម្លៃឡើងដល់ 4002 → **Buy** បើក, SL=3952, TP=4002.5
- ករណី 1: តម្លៃឡើងដល់ 4002.5 មុន → TP ចាប់ **+$0.5** → Position បិទ → Base ថ្មី = 4002.5 → រង់ចាំបន្ត
- ករណី 2: តម្លៃចុះដល់ 3952 មុន → SL ចាប់ **−$50** → Position បិទ → Base ថ្មី = 3952 → រង់ចាំបន្ត

## ⚠️ ការប្រុងប្រយ័ត្នធ្ងន់ធ្ងរ៖ Risk/Reward = 1:100

TP=$0.5 តូចជាង SL=$50 ដល់ទៅ **100 ដង**។ គណនា Win rate ចាំបាច់ (Breakeven) = SL/(SL+TP) = 50/50.5 = **~99%**។ មានន័យថា ត្រូវឈ្នះជាប់ៗគ្នាស្ទើរតែ 100% នៃ Trade ទាំងអស់ទើបស្មើគ្នា — **Loss តែម្តងតែមួយ លុបបំបាត់ចំណេញពី Trade ឈ្នះជាង 100 ដងភ្លាមៗ**។ នេះខុសពីមុន (TP=$2/SL=$10 = 1:5, ត្រូវការ Win rate ~83%) ខ្លាំងណាស់។

ជាក់ស្តែង៖ ការចូលផ្សារញឹកញាប់ + ចំណេញតូចៗគ្មានន័យថាចំណេញសុទ្ធវិជ្ជមានទេ — លុះត្រាតែចំណុចចូល (Trigger, `InpTriggerGapUSD`=$2 ពី Base) ជាទិសដៅត្រឹមត្រូវស្ទើរតែគ្រប់ដង។ សូមតាមដាន Win rate ជាក់ស្តែងលើ Demo ដោយប្រុងប្រយ័ត្នខ្លាំង៖ បើ Win rate ធ្លាក់ក្រោម ~99% សូម្បីតែម្តង គណនីអាចខាតធំរហ័ស។

## ការប្រុងប្រយ័ត្នផ្សេងទៀត

- **TP/SL តូចជាង Broker Minimum Stop Distance** — Gold ជាធម្មតាមាន Minimum Stop Level ពី Broker (ចម្ងាយអប្បបរមារវាងតម្លៃចូល និង TP/SL) ។ `InpTakeProfitUSD`=$0.5 អាចតូចជាងកម្រិតនេះនៅ Broker មួយចំនួន ដែលនាំឲ្យ Order ត្រូវបដិសេធ (Invalid stops)។ EA នឹង Print ការព្រមានក្នុង Log ពេលចាប់ផ្តើម បើលក្ខខណ្ឌនេះកើតឡើង — សូមពិនិត្យ Experts tab
- **គ្មាន Guarantee ចំណេញ** — Broker TP/SL ត្រឹមតែកំណត់ហានិភ័យក្នុងមួយ Trade ប៉ុណ្ណោះ (អតិបរមា $50 × Lot ក្នុងមួយ Trade) មិនមែនធានាលទ្ធផលសរុបវិជ្ជមានទេ
- **Spread/Commission** កាត់រំលោភរាល់ Trade — ពេលចូលផ្សារញឹកញាប់ (TP តូច) Cost នេះកកកុញលឿនជាង
- សូមសាកល្បងលើ **Demo account** ជាមុនសិន និងតាមដានចំនួន Trade/Win rate ជាក់ស្តែងសិន មុននឹងប្រើនៅលើ Real account
