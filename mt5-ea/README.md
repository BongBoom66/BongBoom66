# GridHedge_XAUUSD — MT5 SR + Wick + Strength EA (Exness Cent)

Expert Advisor សម្រាប់ MetaTrader 5 (MQL5) — Trade មាស (XAUUSD) ដោយបញ្ចូលគ្នា **3 គំនិត**៖ Support/Resistance, Wick (កន្ទុយទៀន) Rejection, និង កំលាំងទិញ/លក់ (Volume Strength)។

## របៀបដំណើរការ

វិភាគ **1 ដងក្នុងមួយ Candle ថ្មី** (Timeframe `InpTimeframe`, default M15) — លើ Candle ដែល**បិទរួច**ហើយប៉ុណ្ណោះ (មិនមែន Candle កំពុងបង្កើតទេ ដើម្បីជៀសវាង Repaint)៖

1. **Support/Resistance**៖ ស្កេនរក Fractal Pivot (ចំណុចខ្ពស់/ទាបជាងជិតខាងទាំង `InpSRFractalWing` Bar ទាំងសងខាង) ក្នុង `InpSRLookbackBars` Candle ចុងក្រោយ រកយក Support/Resistance ដែលនៅជិត Candle សញ្ញាបំផុត
2. **Wick Rejection**៖ Candle សញ្ញាត្រូវមាន Wick វែងជាង Body យ៉ាងតិច `InpWickRatio` ដង (Wick ក្រោមវែង = ការពារ Support = Bullish, Wick លើវែង = ច្រានចោល Resistance = Bearish)
3. **Volume Strength**៖ Tick Volume របស់ Candle សញ្ញាត្រូវ **ខ្ពស់ជាង ឬស្មើ** មធ្យម Volume នៃ `InpVolumeAvgBars` Candle មុន (ជា Proxy សម្រាប់កំលាំងទិញ/លក់ ព្រោះ Forex Feed មិនមាន Volume ពិតប្រាកដទេ)

**ចូល Buy** លុះត្រាតែ**ទាំង 3 ចំណុច**ត្រូវគ្នា៖ Candle ទាប (Low) នៅជិត Support (ក្នុងចម្ងាយ `InpSRToleranceUSD`) + Wick ក្រោមវែង + Volume ខ្ពស់។ **ចូល Sell** ដូចគ្នាប៉ុន្តែផ្ទុយវិញត្រង់ Resistance។ **Position តែមួយក្នុងមួយពេល** — TP/SL ដាក់ផ្ទាល់ពី Broker។

## ឯកសារ

- `GridHedge_XAUUSD.mq5` — កូដ EA ពេញលេញ, compile ដោយ MetaEditor (F7) នៅក្នុង MT5

## របៀបប្រើ

1. ចម្លងឯកសារ `GridHedge_XAUUSD.mq5` ទៅក្នុងថត `MQL5/Experts/` នៃ MT5 terminal របស់អ្នក (File → Open Data Folder)
2. បើក MetaEditor ហើយ compile ឯកសារនេះ (F7)
3. បើក Chart នៃ Gold តាម symbol ពិតរបស់ broker Exness Cent របស់អ្នក (ជាធម្មតាមាន suffix ដូចជា `XAUUSDc` — ត្រូវប្រើ symbol ត្រឹមត្រូវនៃ Cent account, មិនមែន `XAUUSD` ធម្មតាទេ)
4. អូស EA ចូល Chart នោះ ហើយបើក "Algo Trading" — Chart timeframe ដែលអូស EA ចូល **មិនចាំបាច់** ដូចគ្នានឹង `InpTimeframe` ទេ (EA ទាញ Candle data ដោយផ្ទាល់តាម Input នេះ)

## Input Parameters

| Parameter | អត្ថន័យ | លំនាំដើម |
|---|---|---|
| `InpLotSize` | Lot size សម្រាប់ Order នីមួយៗ | 0.2 |
| `InpTakeProfitUSD` | ចម្ងាយ Take Profit ពីតម្លៃចូល ($) | 12.0 |
| `InpStopLossUSD` | ចម្ងាយ Stop Loss ពីតម្លៃចូល ($) | 10.0 |
| `InpSlippagePoints` | Slippage អតិបរមាសម្រាប់ market order | 30 |
| `InpTimeframe` | Timeframe សម្រាប់វិភាគ SR/Wick/Volume | M15 |
| `InpSRLookbackBars` | ចំនួន Bar ត្រឡប់ក្រោយសម្រាប់ស្កេនរក SR Pivot | 150 |
| `InpSRFractalWing` | ចំនួន Bar ទាំងសងខាងចាំបាច់ដើម្បីបញ្ជាក់ Pivot | 3 |
| `InpSRToleranceUSD` | ចម្ងាយអតិបរមាពី SR level ដើម្បីរាប់ថា "នៅជិត" ($) | 1.0 |
| `InpWickRatio` | Wick ត្រូវធំជាង Body យ៉ាងតិចប៉ុន្មានដង ទើបរាប់ជា Rejection | 2.0 |
| `InpVolumeAvgBars` | ចំនួន Bar សម្រាប់គណនា Volume មធ្យម (Baseline) | 20 |
| `InpMagicNumber` | Magic number កំណត់អត្តសញ្ញាណ trade របស់ EA នេះ | 20260802 |

## ចំណុចសំខាន់ត្រូវយល់

- **Fractal Pivot** ជាវិធីកំណត់ SR សាមញ្ញបំផុត (Bar ខ្ពស់/ទាបជាងជិតខាងទាំងសងខាង) — មិនមែនវិធីតែមួយគត់ទេ ក៏មិនមែនល្អឥតខ្ចោះទេ ជាពិសេស SR level ចាស់អាចលែងសំខាន់ទៀតហើយ
- **Volume = Tick Volume** (ចំនួនដងតម្លៃប្តូរ) មិនមែន Volume ជួញដូរពិតប្រាកដទេ (Forex/Gold CFD មិនមាន Volume ពិតតាម Broker ភាគច្រើន) — ជា Proxy ប៉ុណ្ណោះ
- **វិភាគតែពេល Candle បិទ** — មិនចូល Order ភ្លាមៗពេលឃើញ Wick កំពុងបង្កើតទេ ត្រូវរង់ចាំ Candle បិទសិន ដូច្នេះមានភាពយឺតបន្តិចប៉ុន្តែជៀសវាង Repaint/False Signal
- **Position តែមួយក្នុងមួយពេល** — ពេលមាន Position បើក EA នឹងមិនវិភាគ Signal ថ្មីទេ រហូតដល់ TP/SL ចាប់សិន

## ការប្រុងប្រយ័ត្ន (Risk warning)

- **គ្មាន Guarantee ចំណេញ** — ការបញ្ចូល SR+Wick+Volume ជាការសម្រេចចិត្តលើគំរូបច្ចេកទេស មិនមែនធានាថាព្យាករណ៍ទីផ្សារបានត្រឹមត្រូវទេ។ Win rate ជាក់ស្តែងអាស្រ័យលើ TP=$12/SL=$10 (Win rate ចាំបាច់ ~45.5%) និងគុណភាពសញ្ញាជាក់ស្តែង
- **Parameter ជាច្រើនត្រូវការការសាកល្បង** (`InpSRFractalWing`, `InpWickRatio`, `InpVolumeAvgBars`, `InpSRToleranceUSD`) — តម្លៃលំនាំដើមជាចំណុចចាប់ផ្តើមសមហេតុផល មិនមែនតម្លៃដែលបានធ្វើ Backtest ផ្ទៀងផ្ទាត់ស្រាប់ទេ
- **Signal កម្រកើតឡើង** — ដោយសារត្រូវការទាំង 3 លក្ខខណ្ឌត្រូវគ្នា ចំនួន Trade ប្រហែលជាតិចជាងគំរូមុនៗច្រើន (លក្ខណៈធម្មតារបស់ Price Action strategy ដែលមិនមែន Scalping ញឹកញាប់)
- សូមសាកល្បងលើ **Demo account** ជាមុនសិន ដោយអង្កេត Log (Experts tab) មើលថាតើ Signal កើតឡើងសមហេតុផលដែរឬទេ មុននឹងប្រើនៅលើ Real account
