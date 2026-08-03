# GridHedge_XAUUSD — MT5 Single-Order Trend EA (Exness Cent)

Expert Advisor សម្រាប់ MetaTrader 5 (MQL5) — **1 Order ក្នុងមួយពេល**, TP/SL ថេរ, តាម Trend៖

- ពេលគ្មាន Position បើក (Flat) តម្លៃទីផ្សារបច្ចុប្បន្នក្លាយជា **Base price**
- រង់ចាំតម្លៃធ្វើចលនាឆ្ងាយ `InpTriggerGapUSD` ($2 default) ពី Base ទិសណាមួយ
- ទិសណាមកដល់មុន បើក Order **មួយប៉ុណ្ណោះ** ភ្លាមៗ (Market order)៖ តម្លៃឡើងដល់ Base+Gap → **Buy**, តម្លៃចុះដល់ Base−Gap → **Sell**
- Order នោះមាន **TP/SL ដាក់ផ្ទាល់ពី Broker** (`InpTakeProfitUSD`=$2, `InpStopLossUSD`=$10 default) — Broker បិទ Order ដោយស្វ័យប្រវត្តិពេលដល់ណាមួយ មិនចាំបាច់ពឹងលើ EA/Terminal ដំណើរការជានិច្ចទេ
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
| `InpTakeProfitUSD` | ចម្ងាយ Take Profit ពីតម្លៃចូល ($) | 2.0 |
| `InpStopLossUSD` | ចម្ងាយ Stop Loss ពីតម្លៃចូល ($) | 10.0 |
| `InpSlippagePoints` | Slippage អតិបរមាសម្រាប់ market order | 30 |
| `InpMagicNumber` | Magic number កំណត់អត្តសញ្ញាណ trade របស់ EA នេះ | 20260802 |

## ឧទាហរណ៍ដំណើរការ

Base = $4000, `InpTriggerGapUSD`=$2, `InpTakeProfitUSD`=$2, `InpStopLossUSD`=$10

- តម្លៃឡើងដល់ 4002 → **Buy** បើក, SL=3992, TP=4004
- ករណី 1: តម្លៃឡើងដល់ 4004 មុន → TP ចាប់ **+$2** → Position បិទ → Base ថ្មី = 4004 → រង់ចាំបន្ត
- ករណី 2: តម្លៃចុះដល់ 3992 មុន → SL ចាប់ **−$10** → Position បិទ → Base ថ្មី = 3992 → រង់ចាំបន្ត

## ការប្រុងប្រយ័ត្ន (Risk warning)

- **Risk/Reward មិនស្មើគ្នា**៖ TP=$2 តូចជាង SL=$10 ៥ដង។ មានន័យថា Win rate ត្រូវការលើសពី **~83%** ទើបចំណេញសុទ្ធវិជ្ជមានក្នុងរយៈពេលវែង (សម្រាប់រាល់ Loss 1 ដង ត្រូវការ Win 5 ដងទើបស្មើគ្នា)។ សូមប្រាកដថាចំណុចចូល (Trigger) ជាទិសដៅដែលមានប្រូបាប៊ីលីតេឈ្នះខ្ពស់ជាមុនសិន មិនមែនគ្រាន់តែពឹងលើ EA ទេ
- **គ្មាន Guarantee ចំណេញ** — Broker TP/SL ត្រឹមតែកំណត់ហានិភ័យក្នុងមួយ Trade ប៉ុណ្ណោះ (អតិបរមា $10 × Lot ក្នុងមួយ Trade) មិនមែនធានាលទ្ធផលសរុបវិជ្ជមានទេ
- **Spread/Slippage** អាចធ្វើឲ្យ TP/SL ជាក់ស្តែងខុសបន្តិចពីតម្លៃកំណត់ (ជាពិសេស `InpSlippagePoints` ពេលបើក Order)
- សូមសាកល្បងលើ **Demo account** ជាមុនសិន និងតាមដានចំនួន Trade/Win rate ជាក់ស្តែងសិន មុននឹងប្រើនៅលើ Real account
