# MT5-MQL5

MetaTrader 5 / MQL5 kaynak ve test deposu.

## İlk EA: SuperTrend V01

`MQL5/Experts/SuperTrend/SuperTrend_EA_V01.mq5` yeni bir başlangıç sürümüdür; önceki V05 veya başka EA'nın yeniden oluşturulmuş kopyası değildir. MetaEditor derlemesi ve Strategy Tester performans testi henüz yapılmadı. Kâr iddiası yoktur.

- Grafik sembolü ve seçilebilir zaman dilimi (varsayılan mevcut grafik).
- MT5 iATR(10), HL2 merkezli bantlar, çarpan 3; 1000 kapanmış mum üzerinden yeniden hesaplama.
- Yön aşağıdan yukarıya dönerse BUY, yukarıdan aşağıya dönerse SELL; sonraki mumun ilk uygun tikinde değerlendirme.
- Sabit 0,01 lot. Başlangıç SL'si SuperTrend bandı; TP, trailing ve dinamik lot yok.
- Kendi ters pozisyonlarını kapatır. Başarısız kapanış sonraki mumlarda yeniden denenir; giriş yalnızca yeni yön değişiminde denenir.
- Her mumda en çok bir giriş denemesi; toplam işlem sayısı için sabit sınır yok. Ekleme/pyramiding stratejisi değildir.
- Yeniden başlatmada eski sinyale giriş yapmaz. Broker lot adımına uymayan ayarlar reddedilir; geçersiz SL ile giriş yapılmaz.
- Pozisyon yönetimi sembol + magic ile sınırlıdır. Her EA/zaman dilimi için farklı magic kullanın.
- Netting hesabında bu sembolü yalnızca bu EA'ya ayırın: aynı sembolde manuel/başka EA işlemleri bir pozisyonda birleşebilir. Gözlenen yabancı magic varsa mum atlanır; bu kontrol paylaşılan netting pozisyonunun sahipliğini garanti etmez. Hedging hesabında ticket ile kapanış yapılır.

## Kurulum

1. MT5 → Dosya → Veri Klasörünü Aç.
2. Bu deponun `MQL5` altındaki klasörleri veri klasöründeki `MQL5` içine kopyalayın; aynı adlı dosya varsa üzerine yazmayın.
3. MetaEditor'de EA'yı açıp F7 ile derleyin. Hata/uyarı raporunu kaydedin.
4. Önce Strategy Tester ve demo hesapta `docs/TEST_PLANI.md` kontrollerini tamamlayın.

## Klasörler

| Yol | Amaç |
| --- | --- |
| MQL5/Experts/SuperTrend | Sürümlenmiş EA kaynakları |
| MQL5/Indicators | Özel göstergeler |
| MQL5/Include | Ortak MQL5 yardımcıları |
| MQL5/Scripts | Tek seferlik betikler |
| MQL5/Files | EA veri dosyaları için yer tutucu |
| presets | Strategy Tester .set ayarları |
| reports | Test raporları ve sonuç kayıtları |
| docs | Kurallar ve doğrulama adımları |

V01 korunur; değişiklikler V02, V03 gibi yeni dosyalarda geliştirilir. Hesap şifresi veya kişisel hesap raporu yüklemeyin.
