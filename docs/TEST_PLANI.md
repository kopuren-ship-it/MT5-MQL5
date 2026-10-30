# SuperTrend V01 doğrulama planı

Durum: kaynak incelemesi yapıldı; MetaEditor / MT5 bu ortamda bulunmadığından derleme ve işlem simülasyonu yapılmadı.

1. MetaEditor F7: sıfır hata; uyarıları inceleyin. Terminal build numarasını kaydedin.
2. Strategy Tester: gerçek tiklere dayalı her tik, sabit sembol/broker/tarih aralığı ve hesap koşulları. 1000 + ATR periyodu kadar ön geçmiş gerekir. H4 başlangıç örneğidir; optimize edilmiş öneri değildir.
3. Görsel mod: kapanmış mum yön değişimi, sonraki mumda tek giriş, başlangıç SL ve ters yönde kapanışı doğrulayın. Aynı parametre/ATR yöntemiyle referans göstergeyi kıyaslayın. Bu uygulama MT5 iATR kullanır; Pine ATR ile birebir eşdeğerlik varsaymayın.
4. SL sonrası aynı trendde yeniden giriş olmamalı. Yeniden başlatmada geçmiş sinyale giriş olmamalı.
5. Alış ve satış, fiyat boşluğu, geçersiz stop mesafesi, yetersiz bakiye, piyasa kapalı ve bağlantı sorunu günlüklerini kontrol edin.
6. Hedging'de farklı magic ve manuel pozisyonlar kapanmamalı. Netting'de ayrı sembol kullanın; yabancı pozisyonda işlem atlanmasını doğrulayın.
7. Eksik geçmişte işlem yapılmamalı; veri geldikten sonra değerlendirme devam etmeli. Başarısız/parsiyel kapanışta yeni ters emir açılmamalı.
8. Isınma penceresini büyüterek sinyal hassasiyetini ölçün: ilk yön yukarı kabul edilir ve her mumda son 1000 mum yeniden hesaplanır; çok uzun tek yönlü dönemlerde başlangıç etkisi olabilir.
9. Rapor: net kâr, PF, maksimum bakiye/varlık düşüşü, işlem sayısı, spread, komisyon, swap, başlangıç bakiyesi, kaldıraç, sembol, TF, dönem, parametreler ve commit SHA.

Başarılı derleme kârlılık kanıtı değildir. Yılları ayrı raporlayın; dönem dışı test ve demo doğrulaması olmadan başarılı strateji olarak işaretlemeyin.
