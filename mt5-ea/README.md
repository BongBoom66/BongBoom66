# GridHedge_XAUUSD — MT5 Single-Order Trend EA (Exness Cent)

Expert Advisor សម្រាប់ MetaTrader 5 (MQL5) — **1 Order ក្នុងមួយពេល**, TP/SL ថេរ, តាម Trend៖

- ពេលគ្មាន Position បើក (Flat) តម្លៃទីផ្សារបច្ចុប្បន្នក្លាយជា **Base price**
- រង់ចាំតម្លៃធ្វើចលនាឆ្ងាយ `InpTriggerGapUSD` ($0.3 default — តូច ដើម្បីឲ្យចូល Order បានញឹកញាប់) ពី Base ទិសណាមួយ
- ទិសណាមកដល់មុន បើក Order **មួយប៉ុណ្ណោះ** ភ្លាមៗ (Market order)៖ តម្លៃឡើងដល់ Base+Gap → **Buy**, តម្លៃចុះដល់ Base−Gap → **Sell**
- Order នោះមាន **TP/SL ដាក់ផ្ទាល់ពី Broker** (`InpTakeProfitUSD`=$0.5, `InpStopLossUSD`=$0.75 default) — Broker បិទ Order ដោយស្វ័យប្រវត្តិពេលដល់ណាមួយ មិនចាំបាច់ពឹងលើ EA/Terminal ដំណើរការជានិច្ចទេ
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
| `InpLotSize` | Lot size សម្រាប់ Order នីមួយៗ | 0.5 |
| `InpTriggerGapUSD` | ចម្ងាយពី Base price ដែលបង្កឲ្យចូល Order ($) — តូចជាង = Order ចូលញឹកញាប់ជាង | 0.3 |
| `InpTakeProfitUSD` | ចម្ងាយ Take Profit ពីតម្លៃចូល ($) | 0.5 |
| `InpStopLossUSD` | ចម្ងាយ Stop Loss ពីតម្លៃចូល ($) | 0.75 |
| `InpSlippagePoints` | Slippage អតិបរមាសម្រាប់ market order | 30 |
| `InpMagicNumber` | Magic number កំណត់អត្តសញ្ញាណ trade របស់ EA នេះ | 20260802 |

## ឧទាហរណ៍ដំណើរការ

Base = $4000, `InpTriggerGapUSD`=$0.3, `InpTakeProfitUSD`=$0.5, `InpStopLossUSD`=$0.75, `InpLotSize`=0.5

- តម្លៃឡើងដល់ 4000.3 → **Buy** បើក (0.5 Lot), SL=3999.55, TP=4000.8
- ករណី 1: តម្លៃឡើងដល់ 4000.8 មុន → TP ចាប់ **+$0.5 × 0.5 Lot** → Position បិទ → Base ថ្មី = 4000.8 → រង់ចាំបន្ត
- ករណី 2: តម្លៃចុះដល់ 3999.55 មុន → SL ចាប់ **−$0.75 × 0.5 Lot** → Position បិទ → Base ថ្មី = 3999.55 → រង់ចាំបន្ត

## ចំណាំសំខាន់៖ ការផ្លាស់ប្តូរ Lot Size

- **`InpLotSize` = 0.5** (កើនពី 0.01 មុន, **50 ដង**) — តាមស្នើច្បាស់លាស់។ Lot ធំជាងនេះមានន័យថា **ចំនួនទឹកប្រាក់ក្នុងគណនីនីមួយ Trade ក៏ធំតាមសមាមាត្រ 50 ដងផងដែរ** (ចម្ងាយតម្លៃដូចគ្នា ប៉ុន្តែ P/L ជាដុល្លារ/សេន ក្នុងគណនីធំជាង)។ សូមប្រាកដថា Balance គណនីអ្នកគ្រប់គ្រាន់ទ្រាំទ្រនឹងទំហំ Lot នេះ ជាពិសេសក្នុងករណី SL ចាប់ជាបន្តបន្ទាប់
- **`InpTakeProfitUSD`** កើនពី $0.25 ទៅ **$0.5** ស្របតាមស្នើ — ធ្វើឲ្យ Risk/Reward ក្លាយជា **1:1.5** (SL=$0.75 ÷ TP=$0.5) — Win rate ចាំបាច់ (Breakeven) = 0.75/(0.75+0.5) = **60%** ដែលសមហេតុផលជាងច្រើនធៀបនឹងជំហានមុនៗ (75% ឬ 99.75%)

## ការប្រុងប្រយ័ត្ន

- **Lot ធំ = ហានិភ័យធំ** — Lot=0.5 មានន័យថា SL មួយដងអាចធ្វើឲ្យខាតច្រើនជាង Lot=0.01 ដល់ 50 ដង។ បើគណនីតូច (ជាពិសេស Cent account) សូមប្រុងប្រយ័ត្នខ្លាំង
- **TP/SL តូចជាង Broker Minimum Stop Distance** — Gold ជាធម្មតាមាន Minimum Stop Level ពី Broker (ចម្ងាយអប្បបរមារវាងតម្លៃចូល និង TP/SL)។ EA នឹង Print ការព្រមានក្នុង Log ពេលចាប់ផ្តើម បើលក្ខខណ្ឌនេះកើតឡើង — សូមពិនិត្យ Experts tab
- **គ្មាន Guarantee ចំណេញ** — Broker TP/SL ត្រឹមតែកំណត់ហានិភ័យក្នុងមួយ Trade ប៉ុណ្ណោះ មិនមែនធានាលទ្ធផលសរុបវិជ្ជមានទេ
- **Spread/Commission** កាត់រំលោភរាល់ Trade — ជាមួយ TP តូច Spread លើ Gold (ជាទូទៅ $0.2-0.5+) អាចស៊ីចំណេញភាគច្រើន ជាពិសេសពេលចូលផ្សារញឹកញាប់ Cost នេះកកកុញលឿនណាស់
- សូមសាកល្បងលើ **Demo account** ជាមុនសិន និងតាមដានចំនួន Trade/Win rate/P&L ជាក់ស្តែងសិន មុននឹងប្រើនៅលើ Real account (ជាពិសេសដោយ Lot ធំដូចនេះ)
