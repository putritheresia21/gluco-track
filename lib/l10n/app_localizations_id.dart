import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'GlucoTrack';

  @override
  String get hello => 'Halo,';

  @override
  String get totalRecords => 'Total Catatan';

  @override
  String get weeklySummary => 'Ringkasan Mingguan';

  @override
  String get lowest => 'Terendah';

  @override
  String get highest => 'Tertinggi';

  @override
  String get yourMission => 'Misi Anda';

  @override
  String get viewAll => 'lihat semua';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get last7Days => '7 Hari Terakhir';

  @override
  String get logoutConfirm => 'Konfirmasi Logout';

  @override
  String get logoutMessage => 'Apakah Anda yakin ingin logout?';

  @override
  String get cancel => 'Batal';

  @override
  String get logout => 'Logout';

  @override
  String yearsOld(int age) {
    return '$age tahun';
  }

  @override
  String get points => 'Poin';

  @override
  String get daysStreak => 'Hari Beruntun';

  @override
  String get missionsCompleted => 'Misi Selesai';

  @override
  String get yourNextMission => 'Misi Berikutnya';

  @override
  String get noMissionsAvailable => 'Belum ada misi tersedia';

  @override
  String get editProfile => 'Edit Profil';

  @override
  String get mgDl => 'mg/dL';

  @override
  String get loading => 'Memuat...';

  @override
  String get noDataYet => 'Belum ada data';

  @override
  String get beforeMeal => 'Sebelum Makan';

  @override
  String get afterMeal => 'Sesudah Makan';

  @override
  String get at => 'pada jam';

  @override
  String get shareResult => 'Bagikan Hasil';

  @override
  String get shareResultMessage => 'Apakah Anda ingin membagikan hasil tes gula darah Anda saat ini?';

  @override
  String get no => 'Tidak';

  @override
  String get yesShare => 'Ya, Bagikan';

  @override
  String get selectDateTimeFirst => 'Pilih tanggal dan waktu terlebih dahulu.';

  @override
  String get glucoseDataSaved => 'Data glukosa berhasil disimpan.';

  @override
  String get failedSaveDatabase => 'Gagal menyimpan data ke database.';

  @override
  String failedSaveData(String error) {
    return 'Gagal menyimpan data: $error';
  }

  @override
  String get glucoseRecord => 'Catatan Glukosa';

  @override
  String get glucoseLevelMgDl => 'Kadar Gula Darah (mg/dL)';

  @override
  String get glucoseLevelRequired => 'Kadar gula darah tidak boleh kosong';

  @override
  String get validNumberRequired => 'Masukkan angka yang valid';

  @override
  String get iotDataLoaded => 'Data dari IoT berhasil dimuat';

  @override
  String get automatic => 'Otomatis';

  @override
  String get iotDeviceData => 'Data dari Perangkat IoT';

  @override
  String get measurementCondition => 'Kondisi Waktu Pengukuran';

  @override
  String get useCurrentTime => 'Gunakan Waktu Saat ini';

  @override
  String get selectDateTime => 'Pilih Tanggal & Waktu';

  @override
  String get dateTime => 'Tanggal & Waktu: ';

  @override
  String get save => 'Simpan';

  @override
  String whatsUp(String name) {
    return 'Apa kabar, $name!';
  }

  @override
  String get haveAnythingToShare => 'Ada yang ingin dibagikan?';

  @override
  String get searchHint => 'Cari kiriman, artikel, atau pengguna...';

  @override
  String get forYou => 'Untuk Anda';

  @override
  String get news => 'Berita';

  @override
  String get failedTriggerEsp32 => 'Gagal mengirim trigger ke ESP32';

  @override
  String get timeoutEsp32 => 'Timeout: ESP32 tidak merespons';

  @override
  String get measureAgain => 'Ukur Lagi';

  @override
  String get startMeasurement => 'Mulai Pengukuran';

  @override
  String get checkGlucoseNow => 'Cek gula darahmu sekarang!';

  @override
  String get start => 'Mulai';

  @override
  String get measurementProcess => 'Proses Pengukuran';

  @override
  String get measurementResult => 'Hasil Pengukuran';

  @override
  String get confidence => 'Keyakinan: ';

  @override
  String get continueText => 'Lanjutkan';

  @override
  String get measurementFailed => 'Pengukuran Gagal';

  @override
  String get articleDetail => 'Detail Artikel';

  @override
  String get social => 'Sosial';

  @override
  String get socialMediaFeed => 'Umpan Media Sosial';

  @override
  String get iotConnection => 'Koneksi IOT';

  @override
  String get testingSocialMedia => 'testing sosmed';

  @override
  String get writeSomethingFirst => 'Tulis sesuatu dulu';

  @override
  String get posted => 'Berhasil dikirim!';

  @override
  String failedToPost(String error) {
    return 'Gagal mengirim: $error';
  }

  @override
  String get post => 'Kirim';

  @override
  String failedToLoadFeed(String error) {
    return 'Gagal memuat feed: $error';
  }

  @override
  String get writeSomethingOrAddImage => 'Tulis sesuatu atau tambahkan gambar';

  @override
  String failedToCreateImage(String error) {
    return 'Gagal membuat gambar: $error';
  }

  @override
  String failedToShare(String error) {
    return 'Gagal membagikan: $error';
  }

  @override
  String congratulationsPoints(int points) {
    return 'Selamat! Anda mendapat $points poin';
  }

  @override
  String get failedToClaimPoints => 'Gagal klaim poin';

  @override
  String get follow => 'Ikuti';

  @override
  String get following => 'Diikuti';

  @override
  String get article1Title => 'Olahraga: Obat yang Tidak Boleh Anda Lewatkan.';

  @override
  String get article1Preview => 'Tetap aktif untuk meningkatkan kesehatan tubuh dan otak. Melewatkan olahraga berarti mengabaikan kesehatan Anda.';

  @override
  String get article1Caption => 'Tetap aktif untuk meningkatkan kesehatan tubuh dan otak. Melewatkan olahraga berarti mengabaikan kesehatan Anda.';

  @override
  String get article1Content => 'Saat orang memikirkan obat, mereka biasanya membayangkan pil, kapsul, atau resep dokter. Namun inilah kenyataannya—salah satu obat paling ampuh yang pernah Anda berikan kepada tubuh Anda tidak berasal dari apotek. Itu berasal dari gerakan. Olahraga adalah jenis obat yang tidak boleh Anda lewatkan, karena ia bekerja pada setiap bagian kesehatan Anda, mulai dari jantung dan paru-paru hingga suasana hati dan kejelasan mental Anda.\n\nCoba pikirkan: hanya 20–30 menit aktivitas fisik sehari dapat meningkatkan sirkulasi darah, memperkuat otot, dan menurunkan risiko penyakit kronis. Namun bukan hanya tubuh—otak Anda juga memanfaatkannya. Olahraga teratur melepaskan endorfin, mengurangi stres, dan bahkan mempertajam fokus. Singkatnya, menggerakkan tubuh bukan hanya tentang tetap bugar; ini tentang tetap hidup dan berkembang.\n\nBagian terbaiknya? Anda tidak butuh keanggotaan gym yang mahal atau peralatan canggih untuk memulai. Jalan cepat, olahraga singkat di rumah, atau bahkan peregangan sambil menonton TV bisa memberikan perbedaan nyata. Yang paling penting adalah konsistensi. Langkah kecil yang dilakukan setiap hari akan membawa lebih banyak hasil daripada memaksakan diri keras sebulan sekali.\n\nJadi, lain kali Anda merasa ingin melewatkan olahraga, ingatlah ini: Anda tidak hanya melewatkan latihan—Anda sedang melewatkan kesempatan untuk berinvestasi dalam kesehatan masa depan Anda. Anggaplah gerakan sebagai obat, karena tubuh dan otak Anda benar-benar tidak dapat berfungsi maksimal tanpanya.';

  @override
  String get article2Title => 'Piring Sehat, Hidup Sehat';

  @override
  String get article2Preview => 'Seimbangkan makanan Anda dengan warna dan variasi. Perubahan kecil membawa hasil besar.';

  @override
  String get article2Caption => 'Seimbangkan makanan Anda dengan warna dan variasi. Perubahan kecil membawa hasil besar.';

  @override
  String get article2Content => 'Gaya hidup sehat dimulai dari makanan yang Anda pilih setiap hari. Membangun piring yang seimbang tidak harus rumit—fokus saja pada variasi dan moderasi. Dengan menyertakan buah-buahan dan sayuran berwarna-warni, protein tanpa lemak, biji-bijian utuh, dan lemak sehat, Anda dapat memberikan apa yang dibutuhkan tubuh untuk tetap kuat dan bertenaga.\n\nSemakin banyak warna yang Anda tambahkan ke makanan Anda, semakin banyak nutrisi yang Anda masukkan ke dalam diet Anda. Makanan dengan warna alami yang kaya—seperti sayuran hijau, wortel, beri, dan paprika—penuh dengan vitamin, mineral, dan antioksidan yang mendukung kesejahteraan secara keseluruhan. Piring yang penuh warna bukan hanya lebih sehat tetapi juga lebih nikmat untuk dimakan.\n\nKontrol porsi adalah kunci lain untuk makan sehat. Anda tidak perlu menghilangkan semua makanan favorit Anda, tetapi Anda dapat mengurangi kelebihan gula, garam, dan lemak tidak sehat. Coba gunakan piring yang lebih kecil, tambahkan lebih banyak sayuran, dan hindari makan berlebihan dengan mendengarkan sinyal lapar tubuh Anda.\n\nPerubahan kecil, seperti menukar nasi putih dengan nasi merah atau memilih makanan yang dipanggang daripada digoreng, dapat memberikan perbedaan besar seiring waktu. Penyesuaian sederhana ini dapat mendukung pencernaan yang lebih baik, tingkat energi yang stabil, dan peningkatan kesehatan jangka panjang.\n\nIngatlah bahwa makan sehat adalah sebuah perjalanan, bukan diet ketat. Tujuannya adalah kemajuan—bukan kesempurnaan. Saat Anda membuat pilihan yang sadar secara konsisten, Anda akan merasa lebih baik, lebih kuat, dan lebih percaya diri dalam kehidupan sehari-hari Anda.';

  @override
  String get article3Title => 'Mengelola Glukosa Jadi Sederhana';

  @override
  String get article3Preview => 'Dengan pilihan yang tepat, Anda bisa tetap berenergi dan mencegah risiko. Kesehatan Anda berharga.';

  @override
  String get article3Caption => 'Dengan pilihan yang tepat, Anda bisa tetap berenergi dan mencegah risiko. Kesehatan ada di tangan Anda.';

  @override
  String get article3Content => 'Mengelola glukosa darah tidak harus terasa membebani. Memahami bagaimana makanan, aktivitas fisik, dan kebiasaan sehari-hari memengaruhi gula darah Anda dapat membantu Anda membuat keputusan yang lebih baik. Dengan pendekatan yang tepat, Anda dapat mempertahankan tingkat energi yang stabil dan mengurangi risiko masalah kesehatan jangka panjang.\n\nKarbohidrat memiliki dampak terbesar pada gula darah, jadi memilih jenis karbohidrat yang tepat sangatlah penting. Biji-bijian utuh, kacang-kacangan, sayuran, dan buah-buahan menawarkan energi yang lambat dan stabil, tidak seperti camilan manis dan makanan olahan yang menyebabkan lonjakan dan penurunan cepat. Kuncinya adalah keseimbangan—bukan eliminasi.\n\nAktivitas fisik yang teratur juga membantu tubuh Anda menggunakan glukosa secara lebih efisien. Bahkan gerakan sederhana seperti berjalan setelah makan, peregangan, atau melakukan olahraga ringan dapat mendukung kadar glukosa yang lebih sehat. Konsistensi lebih penting daripada intensitas.\n\nMemantau kebiasaan Anda dapat membantu Anda memahami apa yang terbaik untuk tubuh Anda. Perhatikan bagaimana makanan tertentu, stres, atau pola tidur memengaruhi energi Anda. Penyesuaian gaya hidup kecil dapat menghasilkan perbaikan besar.\n\nAnda memiliki kekuatan untuk mengendalikan kesehatan Anda. Dengan membuat pilihan yang sadar setiap hari, Anda dapat melindungi kesejahteraan Anda, tetap aktif lebih lama, dan merasa percaya diri dalam mengelola kadar glukosa Anda.';

  @override
  String get article4Title => 'Panduan Anda Menuju Kesehatan Sehari-hari';

  @override
  String get article4Preview => 'Tips praktis untuk hidup yang lebih sehat dan seimbang. Karena kesehatan adalah kekayaan.';

  @override
  String get article4Caption => 'Tips praktis untuk hidup yang lebih sehat dan seimbang. Karena kesehatan adalah kekayaan.';

  @override
  String get article4Content => 'Kesehatan (wellness) bukan hanya tentang menghindari penyakit—ini tentang merasa dalam kondisi terbaik secara fisik, mental, dan emosional. Mengambil langkah sederhana setiap hari dapat menciptakan gaya hidup yang lebih seimbang dan memuaskan. Kebiasaan sehat berkembang seiring waktu, satu pilihan pada satu waktu.\n\nMulailah dengan memberi asupan makanan bergizi bagi tubuh Anda, tetap terhidrasi, dan menjaga pola makan yang teratur. Diet yang seimbang mendukung suasana hati yang stabil, fokus yang lebih baik, dan kekebalan tubuh yang meningkat. Kebiasaan kecil seperti minum cukup air atau memilih makanan utuh dapat memberikan dampak besar.\n\nKesehatan mental sama pentingnya dengan kesehatan fisik. Mengambil istirahat, melatih perhatian penuh (mindfulness), menulis jurnal, atau menghabiskan waktu di alam dapat membantu mengurangi stres dan meningkatkan keseimbangan emosional. Jangan lupa istirahat—tidur yang berkualitas memungkinkan tubuh dan pikiran Anda untuk pulih.\n\nGerakan adalah bagian penting lainnya dari kesehatan. Baik itu berjalan, menari, yoga, atau olahraga, temukan aktivitas yang Anda nikmati sehingga olahraga terasa bermanfaat—bukan terpaksa. Tubuh yang kuat membantu mendukung kehidupan yang aktif dan mandiri.\n\nYang paling penting, bersikaplah baik pada diri sendiri. Kesehatan itu personal dan berbeda untuk setiap orang. Kemajuan mungkin lambat, tetapi konsistensi akan membantu Anda membangun kebiasaan yang bertahan seumur hidup. Kesehatan Anda benar-benar adalah kekayaan terbesar Anda.';

  @override
  String get article5Title => 'Bergerak Setiap Hari, Hidup Lebih Kuat';

  @override
  String get article5Preview => 'Rutinitas sederhana dapat mengubah energi dan kesehatan Anda. Jadikan gerakan sebagai obat harian Anda.';

  @override
  String get article5Caption => 'Rutinitas sederhana dapat mengubah energi dan kesehatan Anda. Jadikan gerakan sebagai obat harian Anda.';

  @override
  String get article5Content => 'Gerakan adalah salah satu hadiah terbaik yang bisa Anda berikan kepada tubuh Anda. Aktivitas fisik harian memperkuat otot, mendukung kesehatan jantung, meningkatkan fleksibilitas, dan meningkatkan suasana hati. Anda tidak butuh keanggotaan gym—mulailah saja dari tempat Anda berada.\n\nRutinitas sederhana seperti berjalan, peregangan, atau naik tangga dapat memberikan perbedaan yang bermakna. Bahkan 10 menit gerakan dapat meningkatkan sirkulasi, mengurangi kekakuan, dan memberi Anda lebih banyak energi sepanjang hari.\n\nOlahraga juga memainkan peran penting dalam menjaga berat badan yang sehat dan mengelola gula darah. Saat tubuh Anda bergerak, ia menggunakan glukosa sebagai bahan bakar, membantu menjaga keseimbangan dan mencegah lonjakan. Gerakan yang konsisten menjaga metabolisme Anda tetap aktif dan efisien.\n\nOlahraga teratur juga bermanfaat bagi kesehatan mental. Aktivitas fisik memicu pelepasan endorfin—kimia alami yang mengurangi stres dan meningkatkan kebahagiaan. Gerakan dapat membantu meningkatkan kualitas tidur, kepercayaan diri, dan suasana hati secara keseluruhan.\n\nJadikan olahraga sesuatu yang Anda nantikan, bukan beban. Pilih aktivitas yang Anda nikmati, tetap konsisten, dan rayakan kemenangan kecil. Semakin banyak Anda bergerak, semakin kuat dan sehat Anda jadinya—satu langkah pada satu waktu.';

  @override
  String get noArticlesFound => 'No articles found';

  @override
  String get shareAsPost => 'GlucoTrack Post';

  @override
  String get shareOptionsPrompt => 'Pilih cara membagikan hasil pengukuran';

  @override
  String get shareAsPostSubtitle => 'Bagikan sebagai post di GlucoTrack';

  @override
  String get otherApps => 'Aplikasi Lain';

  @override
  String get socialAppsSubtitle => 'WhatsApp, Instagram, Facebook, dll';

  @override
  String get sharing => 'Membagikan...';

  @override
  String get bloodGlucoseResult => 'Hasil Pengukuran Gula Darah';

  @override
  String get iotDeviceInvasive => 'Perangkat IoT (Invasive)';

  @override
  String get manualGlucometer => 'Glucometer Manual';

  @override
  String get conditionLabel => 'Kondisi: ';

  @override
  String get footerStayHealthy => '💙 Jaga kesehatan Anda dengan GlucoTrack';

  @override
  String get login => 'Masuk';

  @override
  String get signUp => 'Daftar';

  @override
  String get welcomeBack => 'Selamat Datang Kembali';

  @override
  String get loginToAccount => 'Masuk ke akun Anda';

  @override
  String get enterEmail => 'Masukkan email Anda';

  @override
  String get enterPassword => 'Masukkan kata sandi Anda';

  @override
  String get rememberMe => 'Ingat Saya';

  @override
  String get forgotPassword => 'Lupa Kata Sandi?';

  @override
  String get dontHaveAccount => 'Belum punya akun?';

  @override
  String get alreadyHaveAccount => 'Sudah punya akun?';

  @override
  String get emailPasswordRequired => 'Email dan Kata Sandi wajib diisi.';

  @override
  String get sessionNotActive => 'Sesi belum aktif. Coba lagi.';

  @override
  String get loginFailed => 'Gagal Masuk.';

  @override
  String get enterEmailReset => 'Masukkan email untuk reset kata sandi.';

  @override
  String get checkEmailReset => 'Cek email Anda untuk instruksi reset.';

  @override
  String get createAccount => 'Buat akun baru Anda';

  @override
  String get enterUsername => 'Masukkan nama pengguna Anda';

  @override
  String get male => 'Laki-laki';

  @override
  String get female => 'Perempuan';

  @override
  String get birthDate => 'Tanggal Lahir';

  @override
  String get createPassword => 'Buat kata sandi';

  @override
  String get confirmPassword => 'Konfirmasi kata sandi';

  @override
  String get emailEmpty => 'Email tidak boleh kosong';

  @override
  String get usernameEmpty => 'Nama pengguna tidak boleh kosong';

  @override
  String get selectBirthDate => 'Pilih tanggal lahir Anda';

  @override
  String get passwordMismatch => 'Konfirmasi kata sandi tidak cocok';

  @override
  String get registrationFailed => 'Pendaftaran gagal. Cek email/nama pengguna atau coba lagi.';

  @override
  String get registrationSuccess => 'Pendaftaran berhasil! Silakan cek email Anda.';

  @override
  String get glucoseChart => 'Grafik Glukosa';

  @override
  String get history => 'Riwayat';

  @override
  String get selectDate => 'Pilih Tanggal';

  @override
  String get all => 'Semua';

  @override
  String get low => 'Rendah';

  @override
  String get normal => 'Normal';

  @override
  String get high => 'Tinggi';

  @override
  String get weekly => 'Mingguan';

  @override
  String get monthly => 'Bulanan';

  @override
  String get noDataDateRange => 'Tidak ada data pada rentang tanggal ini';

  @override
  String noDataCategory(String category) {
    return 'Tidak ada data kategori \'\'$category\'\'';
  }

  @override
  String get noHistoryData => 'Belum ada riwayat data';

  @override
  String get noDataAnalysis => 'Belum ada data minggu ini untuk dianalisis.';

  @override
  String get glucoseStability => 'Stabilitas Gula Darah';

  @override
  String get attentionRequired => 'Perhatian Diperlukan';

  @override
  String get highGlucoseTrend => 'Minggu ini gula darah Anda cenderung tinggi. Lebih dari 50% pencatatan di atas normal.';

  @override
  String get hypoglycemiaAlert => 'Waspada Hipoglikemia';

  @override
  String get lowGlucoseTrend => 'Terdeteksi sering terjadi kadar gula rendah. Pastikan makan teratur dan konsultasi dokter.';

  @override
  String get goodJob => 'Kerja Bagus!';

  @override
  String get stableGlucoseMessage => 'Gula darah Anda sangat terkendali minggu ini. Pertahankan pola hidup sehat Anda.';

  @override
  String get fairlyStable => 'Cukup Stabil';

  @override
  String stableVariationMessage(String avg) {
    return 'Variasi gula darah Anda dalam batas wajar. Rata-rata minggu ini $avg mg/dL.';
  }

  @override
  String get average => 'Rata-rata';

  @override
  String get whoCanReply => 'Siapa yang bisa membalas?';

  @override
  String get whoCanReplySubtitle => 'Pilih siapa yang bisa membalas postingan ini.';

  @override
  String get everyone => 'Semua orang';

  @override
  String get followersOnly => 'Hanya pengikut';

  @override
  String get discardPost => 'Buang postingan?';

  @override
  String get discardPostMessage => 'Ini tidak bisa dibatalkan dan draf Anda akan hilang.';

  @override
  String get discard => 'Buang';

  @override
  String get addNewPost => 'Tambah Postingan Baru';

  @override
  String get share => 'Bagikan';

  @override
  String get writeSomethingHere => 'Tulis sesuatu di sini....';

  @override
  String characterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count karakter',
      one: '$count karakter',
    );
    return '$_temp0';
  }

  @override
  String manualGlucoseTask(int count) {
    return '${count}x Pencatatan Manual Gula Darah';
  }

  @override
  String iotGlucoseTask(int count) {
    return '${count}x Pencatatan IoT Gula Darah';
  }

  @override
  String socialPostTask(int count) {
    return '${count}x Posting pembaruan di Media Sosial';
  }

  @override
  String tasksProgress(int completed, int total) {
    return '$completed/$total Tugas';
  }

  @override
  String get completed => 'Selesai';

  @override
  String get claim => 'Klaim';

  @override
  String get justNow => 'Baru saja';

  @override
  String minsAgo(int count) {
    return '$count menit yang lalu';
  }

  @override
  String hoursAgo(int count) {
    return '$count jam yang lalu';
  }

  @override
  String daysAgo(int count) {
    return '$count hari yang lalu';
  }
}
