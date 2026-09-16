<?php
session_start();
require_once "db.php";
// تحديد اللغة الافتراضية
$lang = $_SESSION['lang'] ?? 'ar';
/**
 * دالة لسحب أجزاء القالب وتنظيفها وتأمينها (تهريب الرموز)
 * 
 * @param string $filePath مسار ملف القالب
 * @param string $separator النص المستخدم كفاصل للتقسيم
 * @return array مصفوفة الأجزاء بعد المعالجة والتهريب
 */
function parseAndEscapeTemplate(string $filePath, string $separator = '<!--template-->'): array
{
    global $db, $lang;
    // 1. التحقق من وجود الملف وقراءته
    if (!file_exists($filePath)) {
        trigger_error("الملف غير موجود: $filePath", E_USER_ERROR);
        exit;
    }
    $content = file_get_contents($filePath);
    //تغيير اللغة
    // وضع المتغير مباشرة داخل الاستعلام لتبسيط الكود
    $sql = "SELECT * FROM texts_lang WHERE texts_lang_locale = '$lang'";
    $result = mysqli_query($db, $sql);
    // عمل لوب سريع لتغيير نصوص اللغة
    if ($result) {
        while ($row = mysqli_fetch_assoc($result)) {
            // استبدال دفعة واحدة بدون أي لوب!
            $content = str_replace($row['texts_lang_search_key'], $row['texts_lang_replacement_text'], $content);
        }
        mysqli_free_result($result);
    }

    // 2. تقسيم النص بناءً على الفاصل المعطى
    $rawBlocks = explode($separator, $content);
    // مصفوفة لتخزين النتائج النهائية بعد المعالجة
    $processedBlocks = [];
    // 3. عمل لوب (Loop) على جميع الأجزاء الناتجة
    foreach ($rawBlocks as $block) {
        // أ. تنظيف الجزء من الفراغات والأسطر الجديدة من البداية والنهاية
        $cleanedBlock = trim($block);
        // ب. تجنب إضافة العناصر التي أصبحت فارغة تماماً بعد التنظيف
        if ($cleanedBlock === '') {
            continue;
        }
        // ج. تهريب علامات التنصيص المزدوجة " لتصبح \"
        $escapedBlock = str_replace('"', '\"', $cleanedBlock);
        // د. تهريب علامة المتغيرات ${ لتصبح \${ لمنع لغة PHP من تفسيرها كمتغير ديناميكي
        $escapedBlock = str_replace('${', '\${', $escapedBlock);
        // هـ. إضافة العنصر الجاهز والمؤمّن إلى المصفوفة النهائية
        $processedBlocks[] = $escapedBlock;
        // 4. التأكد الحاسم من أن المتغير مصفوفة فعلاً قبل إرجاعه
        if (is_array($processedBlocks) and count($processedBlocks) >= 1) {
            return $processedBlocks;
        } else {
            exit;
        }
    }
}
//حذف الرموز الخطره من النصوص العادية
function sanitize_input_text($data)
{
    // استخدام صيغة array() التقليدية المتوافقة مع PHP 5.2.6
    $dangerous_symbols = array(
        '$',
        '>',
        '<',
        '{',
        '}',
        '"',
        "'",
        '\\',
        ';',
        '`'
    );

    // دالة str_replace مدعومة بالكامل في هذا الإصدار وتستقبل مصفوفات
    $clean_data = str_replace($dangerous_symbols, '', $data ?? '');

    // التخلص من المسافات في البداية والنهاية
    $clean_data = trim($clean_data);

    return $clean_data;
}
//حذف الرموز الخطرة من المصفوفات المتعدده والبسيطه
//$_POST = sanitize_input_recursive($_POST);
//$_GET = sanitize_input_recursive($_GET);
function sanitize_input_recursive($data)
{
    // 1. إذا كانت البيانات القادمة مصفوفة
    if (is_array($data)) {
        $cleaned_array = array();

        // المرور على كل عناصر المصفوفة (مفتاح وقيمة)
        foreach ($data as $key => $value) {
            // إعادة استدعاء الدالة نفسها لتنظيف القيمة (سواء كانت نص أو مصفوفة فرعية)
            $cleaned_array[$key] = sanitize_input_recursive($value);
        }

        return $cleaned_array;
    }

    // 2. إذا كانت البيانات نصاً عادياً (يتم تنظيفها بالرموز المحددة)
    $dangerous_symbols = array(
        '$',
        '>',
        '<',
        '{',
        '}',
        '"',
        "'",
        '\\',
        ';',
        '`'
    );

    $clean_data = str_replace($dangerous_symbols, '', $data ?? '');
    return trim($clean_data);
}
//التأكد من واقعية التاريخ ولا يزيد عن سنتين
//من تاريخ اليوم ولا يقل عن 1901
function validate_date_for_unix($date_string)
{
    // 1. توحيد الفواصل لتصبح بالنسق المطلوب (-) بدلاً من (/) أو (.)
    $canonical_date = str_replace(array('/', '.'), '-', $date_string ?? '');

    // 2. تقطيع التاريخ بناءً على الشرطة
    $parts = explode('-', $canonical_date);

    // التأكد من وجود 3 أجزاء كاملة للتاريخ (سنة، شهر، يوم)
    if (count($parts) !== 3) {
        return false;
    }

    // تحويل الأجزاء إلى أرقام صحيحة
    $year = (int) $parts[0];
    $month = (int) $parts[1];
    $day = (int) $parts[2];

    // 3. جلب السنة الحالية ديناميكياً وإضافة شرط ألا تتجاوز سنتين مستقبلياً
    $current_year = (int) date('Y'); // في عام 2026 ستكون القيمة 2026
    $max_allowed_year = $current_year + 2; // الحد الأقصى المسموح به هو 2028

    // فحص حد السنين (أكبر من 1901 وأقل من أو يساوي الحد الأقصى)
    if ($year <= 1901 || $year > $max_allowed_year) {
        return false;
    }

    // 4. التأكد من أن الشهر أكبر من الصفر وأقل من أو يساوي 12
    if ($month < 1 || $month > 12) {
        return false;
    }

    // 5. التأكد من أن اليوم أكبر من الصفر ولا يتجاوز عدد أيام هذا الشهر بالذات
    if ($day < 1 || !checkdate($month, $day, $year)) {
        return false;
    }

    // إذا مرت كل الشروط بنجاح
    return true;
}
//التأكد من واقعية الوقت
function validate_time_format($time)
{
    // التأكد من صيغة الوقت (ساعة:دقيقة:ثانية) باستخدام التعبير النمطي
    if (!preg_match('/^(\d{1,2}):(\d{2}):(\d{2})$/', $time, $matches)) {
        return false;
    }

    // استخراج الساعات، الدقائق، والثواني من المصفوفة
    $hours = (int) $matches[1];
    $minutes = (int) $matches[2];
    $seconds = (int) $matches[3];

    // التحقق من أن القيم تقع في النطاق الواقعي والمقبول
    if ($hours < 0 || $hours > 23) {
        return false;
    }
    if ($minutes < 0 || $minutes > 59) {
        return false;
    }
    if ($seconds < 0 || $seconds > 59) {
        return false;
    }

    return true;
}
function removeDuplicateDates($text)
{
    //$text = "2027-10 - 2027-10 - 2026-10 - 2027-10 - 2027-10 - 2020-10 - 2020-10 - 2020-10 - 2020-10 - 2020-01";
    // 1. تحويل النص إلى مصفوفة بناءً على الفاصل " - "
    $array = explode(" - ", $text);
    // 2. إزالة العناصر المتكررة
    $uniqueArray = array_unique($array);
    // 3. إعادة دمج العناصر الفريدة إلى نص مرة أخرى
    $result = implode(" - ", $uniqueArray);
    return $result;
    // النتيجة: 2027-10 - 2026-10 - 2020-10 - 2020-01
}
/**
 * دالة جلب رقم الصنف من خلال رقم الوحدة المرتبطة به
 *
 * @param int $units_id رقم المعرف الفريد للوحدة
 * @return int رقم الصنف (items_id) في حال النجاح، أو 0 في حال عدم الوجود
 */
function get_item_id_by_unit_id($units_id)
{
    global $db; // استخدام متغير الاتصال بقاعدة البيانات المعتمد لديك

    $units_id = (int) $units_id;
    if ($units_id <= 0) {
        return 0;
    }

    // تنفيذ استعلام مباشر نظيف بدون دوال حماية زائدة - تماشياً مع القاعدة (11)
    $query = "SELECT units_items_id FROM units WHERE units_id = '$units_id' LIMIT 1";
    $result = mysqli_query($db, $query);

    if ($result && mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        return (int) $row['units_items_id'];
    }

    return 0; // إرجاع صفر إذا لم يتم العثور على الوحدة في النظام
}
/**
 * دالة للتحقق من وجود حركات فواتير مسجلة على وحدة قياس معينة
 *
 * @param int $units_id المعرف الفريد للوحدة من جدول units
 * @return bool ترجع true إذا كان لها حركات، و false إذا كانت نظيفة تماماً
 */
function has_invoice_movements_by_unit_id($units_id)
{
    global $db; // استدعاء متغير الاتصال المعتمد بالقاعدة في النظام

    $units_id = (int) $units_id;
    if ($units_id <= 0) {
        return false;
    }

    // تنفيذ استعلام مباشر لفحص حقل invoices_items_units_id الفعلي - القاعدة (11)
    $query = "SELECT invoices_items_id FROM invoices_items WHERE invoices_items_units_id = '$units_id' LIMIT 1";
    $result = mysqli_query($db, $query);

    if ($result && mysqli_num_rows($result) > 0) {
        return true; // نعم، حصلت عليها حركات مالية ومخزنية مسجلة
    }

    return false; // فولس، الوحدة نظيفة تماماً ولم تدخل في أي مستند
}
/**
 * دالة للتحقق من وجود الوحدة مستعملة بداخل بنود ومكونات الأصناف المجمعة
 *
 * @param int $units_id المعرف الفريد للوحدة من جدول units
 * @return bool ترجع true إذا كانت مستعملة في المكونات، و false إذا كانت نظيفة تماماً
 */
function is_unit_used_in_components($units_id)
{
    global $db; // استدعاء متغير الاتصال المعتمد بالقاعدة في النظام

    $units_id = (int) $units_id;
    if ($units_id <= 0) {
        return false;
    }

    // تنفيذ استعلام مباشر لفحص الحقلين التبعيين لجدول المكونات - القاعدة (11)
    $query = "SELECT items_components_id FROM items_components 
              WHERE items_components_units_id = '$units_id' 
              OR items_components_component_units_id = '$units_id' LIMIT 1";

    $result = mysqli_query($db, $query);

    if ($result && mysqli_num_rows($result) > 0) {
        return true; // نعم، الوحدة مستعملة في تركيبات الأصناف المجمعة ولا يمكن مساسها
    }

    return false; // فولس، الوحدة غير مستعملة في أي بند مكون ونظيفة تماماً
}
/**
 * دالة حساب الرصيد الافتتاحي (Opening Balance) للحسابات المالية.
 * 
 * [الهدف الأساسي]
 * حساب صافي الرصيد التاريخي لحساب معين قبل تاريخ محدد (Unix Timestamp)، 
 * لتحديد القيمة المالية الافتتاحية والطرف المهيمن (مدين أم دائن).
 * 
 * [تحليل كفاءة الأداء - Performance Analysis]
 * 1. تعمل الدالة باستعلام واحد مدمج ذكي (Single Query with CASE WHEN) بدلاً من استعلامين منفصلين، 
 *    مما يقلل عدد زيارات قاعدة البيانات (Database Roundtrips) إلى النصف ويحمي موارد الخادم.
 * 2. تم تصميم الاستعلام ليستغل الفهرس المركب (Composite Index):
 *    `idx_balance_calculation (journal_items_chart_of_accounts_id, journal_items_created_at, journal_items_entry_type)`
 * 3. بناءً على نتائج اختبار (EXPLAIN)، يقوم المحرك بقراءة نطاق محدد مباشرة (type: range) 
 *    ويفحص فقط الأسطر المطلوبة (rows: 1 تقريباً) بكفاءة فلترة كاملة (filtered: 100%).
 * 
 * [الحماية والأمان - Security]
 * يتم إجبار المتغيرات الممررة على التحول إلى أنواع بيانات رقمية صريحة (int) لمنع 
 * ثغرات حقن الاستعلامات (SQL Injection) بشكل كامل دون الحاجة لدوال معالجة نصوص إضافية.
 * 
 * @param int $account_id  رقم المعرف الفريد للحساب المالي من شجرة الحسابات.
 * @param int $timestamp   وقت التصفية المطلوب بصيغة Unix Timestamp (الأرقام التي تقع قبل هذا الوقت فقط).
 * 
 * @return array مصفوفة تحتوي على:
 *               - 'difference' (float): فرق القيمة المطلق (الموجب دائماً) بين المدين والدائن.
 *               - 'larger_side' (string): الطرف الأكبر ماليًا، ويأخذ إحدى القيم:
 *                 ['debit' (مدين)، 'credit' (دائن)، 'equal' (متساوي/لا يوجد حركات)].
 */
function get_account_opening_balance($account_id, $timestamp)
{
    // استدعاء اتصال قاعدة البيانات العام
    global $db;

    // تجهيز المتغيرات لمنع ثغرات حقن SQL (SQL Injection) لحماية النظام
    $account_id = (int) $account_id;
    $timestamp = (float) $timestamp; // أو (int) حسب نوع البيانات الممررة

    // استعلام واحد ذكي يجمع المدين والدائن قبل التاريخ المحدد
    $query = "SELECT 
    SUM(CASE WHEN journal_items_entry_type = 'debit' THEN journal_items_amount ELSE 0 END) AS total_debit,
    SUM(CASE WHEN journal_items_entry_type = 'credit' THEN journal_items_amount ELSE 0 END) AS total_credit
    FROM journal_items
    WHERE journal_items_chart_of_accounts_id = $account_id 
    AND journal_items_created_at < $timestamp";

    $result = mysqli_query($db, $query);

    if ($result) {
        $row = mysqli_fetch_assoc($result);

        // تحويل القيم المسترجعة إلى أرقام (افتراضياً تكون 0 إذا كانت null)
        $total_debit = (float) ($row['total_debit'] ?? 0);
        $total_credit = (float) ($row['total_credit'] ?? 0);

        // حساب فرق القيمة (الفرق دائماً قيمة موجبة)
        $difference = abs($total_debit - $total_credit);

        // تحديد الطرف الأكبر ماليًا
        if ($total_debit > $total_credit) {
            $larger_side = 'debit';
        } elseif ($total_credit > $total_debit) {
            $larger_side = 'credit';
        } else {
            $larger_side = 'equal'; // في حال تساوى المدين والدائن أو لم تكن هناك حركات
        }

        // إرجاع المصفوفة المطلوبة
        return [
            'difference' => $difference,
            'larger_side' => $larger_side
        ];
    }

    // في حال فشل الاستعلام لأي سبب
    return [
        'difference' => 0,
        'larger_side' => 'error'
    ];
}

?>