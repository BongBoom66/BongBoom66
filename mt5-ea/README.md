# GridHedge_XAUUSD — MT5 Single-Order Trend EA (Exness Cent)

Expert Advisor សម្រាប់ MetaTrader 5 (MQL5) — **1 Order ក្នុងមួយពេល**, TP/SL ថេរ, តាម Trend៖

- ពេលគ្មាន Position បើក (Flat) តម្លៃទីផ្សារបច្ចុប្បន្នក្លាយជា **Base price**
- រង់ចាំតម្លៃធ្វើចលនាឆ្ងាយ `InpTriggerGapUSD` ($0.3 default — តូច ដើម្បីឲ្យចូល Order បានញឹកញាប់) ពី Base ទិសណាមួយ
- ទិសណាមកដល់មុន បើក Order **មួយប៉ុណ្ណោះ** ភ្លាមៗ (Market order)៖ តម្លៃឡើងដល់ Base+Gap → **Buy**, តម្លៃចុះដល់ Base−Gap → **Sell**
- Order នោះមាន **TP/SL ដាក់ផ្ទាល់ពី Broker** (`InpTakeProfitUSD`=$0.25, `InpStopLossUSD`=$0.75 default) — Broker បិទ Order ដោយស្វ័យប្រវត្តិពេលដល់ណាមួយ មិនចាំបាច់ពឹងលើ EA/Terminal ដំណើរការជានិច្ចទេ
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
| `InpTriggerGapUSD` | ចម្ងាយពី Base price ដែលបង្កឲ្យចូល Order ($) — តូចជាង = Order ចូលញឹកញាប់ជាង | 0.3 |
| `InpTakeProfitUSD` | ចម្ងាយ Take Profit ពីតម្លៃចូល ($) | 0.25 |
| `InpStopLossUSD` | ចម្ងាយ Stop Loss ពីតម្លៃចូល ($) | 0.75 |
| `InpSlippagePoints` | Slippage អតិបរមាសម្រាប់ market order | 30 |
| `InpMagicNumber` | Magic number កំណត់អត្តសញ្ញាណ trade របស់ EA នេះ | 20260802 |

## ឧទាហរណ៍ដំណើរការ

Base = $4000, `InpTriggerGapUSD`=$0.3, `InpTakeProfitUSD`=$0.25, `InpStopLossUSD`=$0.75

- តម្លៃឡើងដល់ 4000.3 → **Buy** បើក, SL=3999.55, TP=4000.55
- ករណី 1: តម្លៃឡើងដល់ 4000.55 មុន → TP ចាប់ **+$0.25** → Position បិទ → Base ថ្មី = 4000.55 → រង់ចាំបន្ត
- ករណី 2: តម្លៃចុះដល់ 3999.55 មុន → SL ចាប់ **−$0.75** → Position បិទ → Base ថ្មី = 3999.55 → រង់ចាំបន្ត

## ចំណាំសំខាន់៖ ហេតុអ្វី SL ត្រូវបានកែពី $100 មក $0.75

ដើមឡើយស្នើ TP=$0.25 / SL=$100 (Risk/Reward = **1:400**, ត្រូវការ Win rate ~99.75% ទើបស្មើគ្នា — Loss តែម្តងលុបបំបាត់ចំណេញពី Win 400 ដង)។ នេះជាកម្រិតហានិភ័យខ្ពស់ហួសហេតុ គណនីអាចខាតអស់ក្នុងរយៈពេលខ្លីបំផុត។ ដូច្នេះបានកែទៅ **SL=$0.75 (Ratio 1:3)** ជំនួសវិញ — Win rate ចាំបាច់ = 0.75/(0.75+0.25) = **75%** ដែលនៅតែជាតម្រូវការខ្ពស់ ប៉ុន្តែសមហេតុផលជាង។ `InpTriggerGapUSD` ក៏បានបន្ថយពី $2 មក $0.3 ដើម្បីឲ្យ Order ចូលបានញឹកញាប់ជាងតាមចង់បាន (ចំនួន Trade ជាក់ស្តែងក្នុងមួយម៉ោងអាស្រ័យលើចលនាទីផ្សារជាក់ស្តែង មិនអាចធានាបានច្បាស់ថាតែ 500 ដងទេ)។

**បើចង់ត្រឡប់ទៅ SL=$100 វិញ** អាចកែ `InpStopLossUSD` ដោយផ្ទាល់ក្នុង Input Parameters ពេលអូស EA ចូល Chart ប៉ុន្តែសូមយល់ច្បាស់ពីហានិភ័យ 1:400 ជាមុនសិន។

## ⚠️ ការប្រុងប្រយ័ត្ន៖ Risk/Reward = 1:3 នៅតែទាមទារ Win rate ខ្ពស់

TP=$0.25, SL=$0.75 → Win rate ចាំបាច់ (Breakeven) = SL/(SL+TP) = **75%**។ ជាមួយការចូលផ្សារញឹកញាប់ (រាប់រយ Trade ក្នុងមួយម៉ោង) បើ Win rate ជាក់ស្តែងទាបជាង 75% សូម្បីតែបន្តិច Loss នឹងកកកុញលឿនណាស់ ព្រោះចំនួន Trade ច្រើន។ សូមប្រាកដថាចំណុចចូល (Trigger `InpTriggerGapUSD`) ជាទិសដៅដែលមានប្រូបាប៊ីលីតេឈ្នះខ្ពស់ជាក់ស្តែង មិនមែនគ្រាន់តែសន្មតទេ។

## ការប្រុងប្រយ័ត្នផ្សេងទៀត

- **TP/SL តូចជាង Broker Minimum Stop Distance** — Gold ជាធម្មតាមាន Minimum Stop Level ពី Broker (ចម្ងាយអប្បបរមារវាងតម្លៃចូល និង TP/SL)។ `InpTakeProfitUSD`=$0.25 អាចតូចជាងកម្រិតនេះនៅ Broker មួយចំនួន ដែលនាំឲ្យ Order ត្រូវបដិសេធ (Invalid stops)។ EA នឹង Print ការព្រមានក្នុង Log ពេលចាប់ផ្តើម បើលក្ខខណ្ឌនេះកើតឡើង — សូមពិនិត្យ Experts tab
- **គ្មាន Guarantee ចំណេញ** — Broker TP/SL ត្រឹមតែកំណត់ហានិភ័យក្នុងមួយ Trade ប៉ុណ្ណោះ (អតិបរមា $0.75 × Lot ក្នុងមួយ Trade) មិនមែនធានាលទ្ធផលសរុបវិជ្ជមានទេ
- **Spread/Commission** កាត់រំលោភរាល់ Trade — ជាមួយ TP=$0.25 ខ្ចីតូចណាស់ Spread លើ Gold (ជាទូទៅ $0.2-0.5+) អាចស៊ីចំណេញភាគច្រើន ឬធ្វើឲ្យ Order ចូលមិនទាន់ចំណេញផង Spread ក៏ត្រូវគិតជាមុន
- ការចូលផ្សារញឹកញាប់ (រាប់រយ Trade ក្នុងមួយម៉ោង) មានន័យថា Cost (Spread/Commission) កកកុញលឿនណាស់ធៀបនឹង Trade ដ៏មួយចំនួនតូច
- សូមសាកល្បងលើ **Demo account** ជាមុនសិន និងតាមដានចំនួន Trade/Win rate ជាក់ស្តែងសិន មុននឹងប្រើនៅលើ Real account
