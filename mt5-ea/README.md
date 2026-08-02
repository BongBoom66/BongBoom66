# GridHedge_XAUUSD — MT5 Grid Hedge EA (Exness Cent)

Expert Advisor មួយសម្រាប់ MetaTrader 5 (MQL5) ត្រូវបានរចនាឡើងតាមតម្រូវការ៖

- ដាក់ Layer ចំនួន 10 (កំណត់បាន) ខាង **Buy** និង 10 ខាង **Sell** គំលាតគ្នា **$2** (កំណត់បាន) គិតចាប់ពីតម្លៃចាប់ផ្តើម (base price)
- ពេលតម្លៃប៉ះកម្រិតនីមួយៗ EA បើក **Market order** ភ្លាមៗ (មិនមែន pending order ទេ)
- Lot size ថេរដូចគ្នាគ្រប់ Layer
- ប្រសិនបើខាង Buy ឬខាង Sell ម្ខាងណាមួយចូលគ្រប់ទាំង 10 Layer មុនគេ → EA នឹង**បិទ Position ទាំងអស់** ភ្លាមៗ រួច**សាកគំរូ Grid ថ្មី** ដោយតម្រឹមតម្លៃចាប់ផ្តើមថ្មីនៅត្រង់តម្លៃទីផ្សារបច្ចុប្បន្ន

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
| `InpLotSize` | Lot size សម្រាប់ Layer នីមួយៗ (ថេរដូចគ្នាទាំងអស់) | 0.01 |
| `InpGapUSD` | គំលាតតម្លៃរវាង Layer ($) | 2.0 |
| `InpLayers` | ចំនួន Layer ក្នុងមួយខាង (Buy/Sell) | 10 |
| `InpSlippagePoints` | Slippage អតិបរមាសម្រាប់ market order | 30 |
| `InpProfitTargetUSD` | បើកំណត់ (> 0) នឹងបិទ+សាកដើមវិញ ភ្លាមៗពេល floating profit សរុបដល់តម្លៃនេះ ដោយមិនចាំបាច់រង់ចាំគ្រប់ 10 Layer | 0 (disabled) |
| `InpMagicNumber` | Magic number កំណត់អត្តសញ្ញាណ trade របស់ EA នេះ | 20260802 |

## ការប្រុងប្រយ័ត្ន (Risk warning)

EA នេះជាប្រភេទ **Grid/Hedge** ដែលបើកចំណាត់ការជាបន្តបន្ទាប់តាមទិសដៅដដែល (មិនមាន Stop Loss ក្នុងកម្រិត Layer នីមួយៗទេ)។ ប្រសិនបើទីផ្សាររត់ខ្លាំងទៅទិសណាមួយដោយបន្ត លុយដែលត្រូវប្រើនឹងកើនឡើងតាម Layer ដែលចូល (គ្រប់ Layer ប្រើ Lot ថេរដូចគ្នា ដូច្នេះហានិភ័យកើនជាលីនេអ៊ែរតាមចំនួន Layer ដែលបានចូល មិនមែនជា Martingale ទេ)។ សូមសាកល្បងលើ **Demo account** ជាមុនសិន និងគណនាទំហំ Drawdown អតិបរមាដែលអាចកើតឡើង (10 Layer × Lot × គំលាតតម្លៃអតិបរមា) មុននឹងប្រើនៅលើ Real account។
