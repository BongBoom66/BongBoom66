# GridHedge_XAUUSD — MT5 Single-Order Trend EA (Exness Cent)

Expert Advisor សម្រាប់ MetaTrader 5 (MQL5) — **1 Order ក្នុងមួយពេល**, TP/SL ថេរ, តាម Trend៖

- ពេលគ្មាន Position បើក (Flat) តម្លៃទីផ្សារបច្ចុប្បន្នក្លាយជា **Base price**
- រង់ចាំតម្លៃធ្វើចលនាឆ្ងាយ `InpTriggerGapUSD` ($0.3 default — តូច ដើម្បីឲ្យចូល Order បានញឹកញាប់) ពី Base ទិសណាមួយ
- ទិសណាមកដល់មុន បើក Order **មួយប៉ុណ្ណោះ** ភ្លាមៗ (Market order)៖ តម្លៃឡើងដល់ Base+Gap → **Buy**, តម្លៃចុះដល់ Base−Gap → **Sell**
- Order នោះមាន **TP/SL ដាក់ផ្ទាល់ពី Broker** (`InpTakeProfitUSD`=$12, `InpStopLossUSD`=$10 default) — Broker បិទ Order ដោយស្វ័យប្រវត្តិពេលដល់ណាមួយ មិនចាំបាច់ពឹងលើ EA/Terminal ដំណើរការជានិច្ចទេ
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
| `InpTakeProfitUSD` | ចម្ងាយ Take Profit ពីតម្លៃចូល ($) | 12.0 |
| `InpStopLossUSD` | ចម្ងាយ Stop Loss ពីតម្លៃចូល ($) | 10.0 |
| `InpSlippagePoints` | Slippage អតិបរមាសម្រាប់ market order | 30 |
| `InpMagicNumber` | Magic number កំណត់អត្តសញ្ញាណ trade របស់ EA នេះ | 20260802 |

## ឧទាហរណ៍ដំណើរការ

Base = $4000, `InpTriggerGapUSD`=$0.3, `InpTakeProfitUSD`=$12, `InpStopLossUSD`=$10, `InpLotSize`=0.5

- តម្លៃឡើងដល់ 4000.3 → **Buy** បើក (0.5 Lot), SL=3990.3, TP=4012.3
- ករណី 1: តម្លៃឡើងដល់ 4012.3 មុន → TP ចាប់ **+$12 × 0.5 Lot** → Position បិទ → Base ថ្មី = 4012.3 → រង់ចាំបន្ត
- ករណី 2: តម្លៃចុះដល់ 3990.3 មុន → SL ចាប់ **−$10 × 0.5 Lot** → Position បិទ → Base ថ្មី = 3990.3 → រង់ចាំបន្ត

## ចំណាំសំខាន់៖ TP=$12 / SL=$10 (Risk/Reward = 1:1.2)

`InpTakeProfitUSD`/`InpStopLossUSD` ត្រូវបានកែទៅ **$12 / $10** — Win rate ចាំបាច់ (Breakeven) = 10/(10+12) = **~45.5%** ដែលសមហេតុផលណាស់ (ទាបជាង 50% ថែមទៀត)។

**ចំណាំ**៖ តម្លៃទាំងនេះដើមឡើយស្នើសម្រាប់ Idea ផ្សេង — បើក **Buy+Sell ព្រមគ្នា** ត្រង់តម្លៃដូចគ្នា ដោយគិតថា ពេលខាងមួយដាច់ SL ខាងម្ខាងទៀតប្រហែលជាមកដល់ TP វិញ ចំណេញសុទ្ធ $2។ ការគណនាបង្ហាញថា Idea នេះ**មិនមែនជា "ធានាចំណេញ" ទេ** (សូមមើលចំណុចខាងក្រោម) ដូច្នេះបានប្តូរមកប្រើ Logic **តាម Trend ម្ខាងតែមួយ** ដដែល (ចូល Buy ឬ Sell អាស្រ័យលើទិសដៅតម្លៃចេញពី Base) ដោយត្រឹមតែផ្លាស់ប្តូរតម្លៃ TP/SL ទៅជា $12/$10 ប៉ុណ្ណោះ។

### ហេតុអ្វី "Buy+Sell ព្រមគ្នា, SL=$10/TP=$12" មិនមែនធានាចំណេញ $2

ប្រសិនបើតម្លៃឡើងដល់ SL ខាង Sell (−$10) មុន, Buy នៅតែបើក ត្រូវការតែ $2 បន្ថែមទៀតដល់ TP។ ប៉ុន្តែបើតម្លៃមិនបន្តទេ ត្រឡប់ក្រោយវិញ Buy អាចដាច់ SL ខ្លួនឯង (ចម្ងាយ $20 ពីចំណុចបច្ចុប្បន្ន) នាំឲ្យខាតសរុប **−$20** មិនមែន +$2 ទេ។ តាមទ្រឹស្តី Random Walk (ចម្ងាយ TP=$2 ខ្លីជាង SL=$20 ដល់ទៅ 10 ដង)៖ P(ដល់ TP មុន)≈91%, P(ដល់ SL មុន)≈9% — Expected Value = 0.91×(+2) + 0.09×(−20) ≈ **$0** (ស្ទើរតែសូន្យ, គ្មានចំណេញបន្ថែមទេ គ្រាន់តែផ្លាស់ទីរូបរាងហានិភ័យ) ហើយបន្ថែម Spread ពីការបើក 2 Position ព្រមគ្នា លទ្ធផលពិតប្រាកដទំនងជាអវិជ្ជមានបន្តិចទៀត។

## ការប្រុងប្រយ័ត្ន

- **Lot ធំ = ហានិភ័យធំ** — Lot=0.5 ជាមួយ SL=$10 មានន័យថា Loss មួយដងអាចខាតច្រើនណាស់ (SL $10 × 0.5 Lot × Contract size — សូមគណនាជាក់ស្តែងតាម Symbol របស់ Broker)។ បើគណនីតូច (ជាពិសេស Cent account) សូមប្រុងប្រយ័ត្នខ្លាំង ឬកាត់បន្ថយ `InpLotSize`
- **TP/SL តូចជាង Broker Minimum Stop Distance** — Gold ជាធម្មតាមាន Minimum Stop Level ពី Broker (ចម្ងាយអប្បបរមារវាងតម្លៃចូល និង TP/SL)។ EA នឹង Print ការព្រមានក្នុង Log ពេលចាប់ផ្តើម បើលក្ខខណ្ឌនេះកើតឡើង — សូមពិនិត្យ Experts tab
- **គ្មាន Guarantee ចំណេញ** — Broker TP/SL ត្រឹមតែកំណត់ហានិភ័យក្នុងមួយ Trade ប៉ុណ្ណោះ មិនមែនធានាលទ្ធផលសរុបវិជ្ជមានទេ។ Win rate ~45.5% គ្រាន់តែជាកម្រិត Breakeven តាមទ្រឹស្តី — ជាក់ស្តែងអាស្រ័យលើថាតើចំណុចចូល (`InpTriggerGapUSD`) ជាទិសដៅត្រឹមត្រូវញឹកញាប់ប៉ុណ្ណាដែរ
- **Spread/Commission** កាត់រំលោភរាល់ Trade — ជាពិសេសពេលចូលផ្សារញឹកញាប់ (`InpTriggerGapUSD`=$0.3 តូច) Cost នេះកកកុញលឿន
- សូមសាកល្បងលើ **Demo account** ជាមុនសិន និងតាមដានចំនួន Trade/Win rate/P&L ជាក់ស្តែងសិន មុននឹងប្រើនៅលើ Real account (ជាពិសេសដោយ Lot ធំដូចនេះ)
