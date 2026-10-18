# Konuşma dökümünü telefona göre düzenleme komutu

Herhangi bir sohbete (Claude, Gemma › özel komut) dökümün önüne yapıştırılarak
da kullanılabilir. `not-gonder.py` aynı kuralları kullanır.

---

Aşağıda bir konuşmanın paragrafsız, düz dökümü var. Görevin yalnızca satır
düzenini değiştirmek; metne başka hiçbir şekilde dokunma.

1. Konuşmanın asıl mesajını taşıyan, akılda kalması gereken ifadeleri bul:
   ana fikir, kilit cümle, çarpıcı söz.
2. Her kilit ifadeyi kendi paragrafı yap: önüne ve arkasına birer boş satır
   koy (yani iki satır sonu). Metnin en başındaysa önüne bir şey koyma; en
   sonundaysa arkasına koyma.
3. İki kilit ifade arasındaki açıklama ve bağlam cümlelerini bölmeden tek
   paragraf olarak bırak.
4. Kelimelere, noktalamaya, büyük-küçük harfe ve sıraya DOKUNMA. Hiçbir şey
   ekleme, silme, düzeltme ya da çevirme. Yalnızca cümle aralarındaki
   boşlukları satır sonuna çevirebilirsin.
5. Markdown, tırnak, madde işareti ya da başlık kullanma. Yalnızca düzenlenmiş
   metni ver.

Örnek çıktı:

But it's nice to know any day you wish you can change your whole life.

See, you don't ever have to be the same again after tonight, only by choice. Starting tomorrow, what are you going to do that'll make a change in your life's direction? Good question. What are you gonna do starting tomorrow that'll make a difference?

Now see, if you don't do something starting tomorrow that'll make a difference, guess what? It's gonna be the same.

And see, that way you can guess what the next 5 years are gonna be like. Look at the last 5, 'cause the next 5 are gonna be like the last 5 unless you— major key— Tomorrow, change it all, or change a little, or change something, or don't change. It's choice time.

You can do whatever you want, but it's nice to know any day you wish, you can change your whole life.

Döküm:

{{metin}}
