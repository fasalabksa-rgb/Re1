-- phpMyAdmin SQL Dump
-- version 4.9.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: 13 سبتمبر 2026 الساعة 13:25
-- إصدار الخادم: 8.0.17
-- PHP Version: 7.3.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `accounting`
--

-- --------------------------------------------------------

--
-- بنية الجدول `admin_settings`
--

CREATE TABLE `admin_settings` (
  `admin_settings_id` int(11) NOT NULL COMMENT 'المعرف الفريد والآلي لرقم الصلاحية أو القيد العام',
  `admin_settings_key` varchar(100) NOT NULL COMMENT 'الاسم البرمجي الفريد للقيد باللغة الإنجليزية (مثال: user_12_allowed_warehouses)',
  `admin_settings_value` text NOT NULL COMMENT 'قيمة القيد أو المصفوفة مخزنة كنص طويل (مثل قيم JSON للمستودعات أو الحسابات المسموحة)',
  `admin_settings_description` text NOT NULL COMMENT 'نبذة توضيحية باللغة العربية تشرح ما يُجبر المستخدمين عليه من خلال هذا القيد',
  `admin_settings_updated_at` bigint(20) NOT NULL COMMENT 'طابع وقت يونكس الرقمي (Unix Timestamp 64-bit) لآخر تحديث للقيد'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول إعدادات وقيود المشرف';

-- --------------------------------------------------------

--
-- بنية الجدول `asset_depreciations`
--

CREATE TABLE `asset_depreciations` (
  `asset_depreciations_id` int(11) NOT NULL COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي لسجل إهلاك الأصل الثابت',
  `asset_depreciations_chart_of_accounts_id` int(11) NOT NULL COMMENT 'الترتيب الثاني: رقم المعرف الفريد للأصل الثابت المرتبط من جدول دليل الحسابات الرئيسي',
  `asset_depreciations_current_value` decimal(15,4) NOT NULL DEFAULT '0.0000' COMMENT 'قيمة الأصل الآن الحالية في تاريخ اللحظة قبل احتساب الإهلاك الجديد المعني بالفترة',
  `asset_depreciations_years_count` int(11) NOT NULL COMMENT 'عدد سنوات الإهلاك الكلية المقدرة للعمر الإنتاجي لهذا الأصل الثابت المدرج',
  `asset_depreciations_book_value` decimal(15,4) NOT NULL DEFAULT '0.0000' COMMENT 'القيمة الدفترية للأصل (الخردة/المتبقية) المتوقعة بعد مرور عدد السنوات المدرج الكلية لعمره الإنتاجي',
  `asset_depreciations_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت إنشاء سجل الإهلاك في النظام مخزن كـ Unix Timestamp رقمي 64 بت لتفادي مشاكل عام 2038'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول إهلاك الأصول الثابتة';

-- --------------------------------------------------------

--
-- بنية الجدول `attachments`
--

CREATE TABLE `attachments` (
  `attachments_id` int(11) NOT NULL COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي لسجل المرفق الرقمي',
  `attachments_source_type` enum('invoice','voucher','journal_entry') NOT NULL COMMENT 'الترتيب الثاني: نوع القسم أو المستند المالي الأصلي (invoice فاتورة، voucher سند، journal_entry قيد يومية)',
  `attachments_source_id` int(11) NOT NULL COMMENT 'رقم المعرف الفريد (ID) للمستند الأصلي بناءً على اختيار نوع القسم المحدد أعلاه لربط المرفق به',
  `attachments_file_name` varchar(255) NOT NULL COMMENT 'اسم الملف الأصلي المرفق مع الامتداد (مثال: scan_invoice_45.pdf أو receipt_image.png)',
  `attachments_file_path` varchar(500) NOT NULL COMMENT 'المسار الرقمي الكامل أو الرابط لتخزين الملف على السيرفر أو السحابة لاستدعائه برمجياً',
  `attachments_file_size` int(11) NOT NULL COMMENT 'حجم الملف المرفق مخزن بالبايت (Bytes) لمتابعة قيود مساحات التخزين بالنظام',
  `attachments_is_active` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'حالة المرفق في النظام: 1 نشط ومعتمد، 0 مؤرشف أو معطل ولا يظهر للمستخدم',
  `attachments_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت رفع وإدراج المرفق مخزن كـ Unix Timestamp رقمي 64 بت لتفادي مشاكل عام 2038'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول المرفقات الموحد';

-- --------------------------------------------------------

--
-- بنية الجدول `branches_warehouses`
--

CREATE TABLE `branches_warehouses` (
  `branches_warehouses_id` int(11) NOT NULL COMMENT 'المعرف الفريد والآلي للسجل (المفتاح الأساسي)',
  `branches_warehouses_parent_id` int(11) NOT NULL DEFAULT '0' COMMENT 'الترتيب الثاني: يربط بالموقع الأعلى، يأخذ القيمة 0 إذا كان فرعاً رئيسياً علوياً، ويأخذ رقم المعرف المرجعي (id) إذا كان مستودعاً أو فرعاً تابعاً لموقع آخر',
  `branches_warehouses_code` varchar(50) NOT NULL COMMENT 'كود الفرع أو المستودع الفريد الذي يضعه المستخدم يدوياً لسهولة البحث والاستدعاء والربط المالي في الفواتير',
  `branches_warehouses_name` varchar(150) NOT NULL COMMENT 'اسم الفرع أو المستودع بالكامل (مثل: فرع جدة، مستودع المواد الخام، مخزن المعرض)',
  `branches_warehouses_allow_stock` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'سؤال منطقي: هل يقبل هذا السجل تخزين وحركات المخزون؟ 1 (نعم/مستودع تنفيذي تودع فيه البضاعة)، 0 (لا/فرع تجميعي للتقارير ويُمنع تخزين بضاعة فيه آلياً)',
  `branches_warehouses_is_active` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'حالة السجل في النظام: 1 نشط ومتاح، 0 موقف لمنع عمل فواتير أو تحويلات مخزنية جديدة عليه',
  `branches_warehouses_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت إنشاء السجل مخزن كرقم صحيح (Unix Timestamp 64-bit) لتفادي كافة مشاكل التوقيت ومستقبل عام 2038'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول الفروع والمستودعات الهرمي';

-- --------------------------------------------------------

--
-- بنية الجدول `chart_of_accounts`
--

CREATE TABLE `chart_of_accounts` (
  `chart_of_accounts_id` int(11) NOT NULL COMMENT 'المعرف الفريد والآلي للحساب (المفتاح الأساسي)',
  `chart_of_accounts_parent_id` int(11) NOT NULL DEFAULT '0' COMMENT 'الترتيب الثاني: يربط بالحساب الأعلى، يأخذ القيمة 0 إذا كان حساباً رئيسياً علوياً، ويأخذ رقم المعرف المرجعي (id) إذا كان فرعاً تابعاً لحساب آخر',
  `chart_of_accounts_code` varchar(50) NOT NULL COMMENT 'رقم أو كود الحساب المحاسبي الفريد الذي يضعه المستخدم يدوياً لسهولة البحث والاستدعاء وعمل التقارير المالية',
  `chart_of_accounts_name` varchar(150) NOT NULL COMMENT 'اسم الحساب المحاسبي بالكامل (مثل: الأصول المتداولة، حساب العملاء الثابت، الصندوق)',
  `chart_of_accounts_allow_transactions` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'سؤال منطقي: هل يقبل الحساب ربط القيود والعمليات؟ 1 (نعم/حساب فرعي تنفيذي)، 0 (لا/حساب رئيسي تجميعي يُمنع ربطه بالعمليات المحاسبية)',
  `chart_of_accounts_allow_delete` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'سؤال منطقي: هل يقبل هذا الحساب الحذف؟ 1 (نعم متاح للحذف)، 0 (لا/حساب ثابت ومحمي برمجياً يعتمد عليه النظام كحساب العملاء ويُمنع حذفه)',
  `chart_of_accounts_type` enum('debit','credit') NOT NULL COMMENT 'طبيعة الحساب الأصلية: debit (مدين مثل الأصول والمصروفات)، credit (دائن مثل الإيرادات والالتزامات وحقوق الملكية)',
  `chart_of_accounts_is_active` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'حالة الحساب في النظام: 1 نشط ومتاح، 0 موقف لمنع عمل قيود جديدة عليه',
  `chart_of_accounts_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت إنشاء حساب مخزن كرقم صحيح (Unix Timestamp 64-bit) لتفادي كافة مشاكل التوقيت والمستقبل'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول دليل الحسابات الهرمي';

-- --------------------------------------------------------

--
-- بنية الجدول `cost_centers`
--

CREATE TABLE `cost_centers` (
  `cost_centers_id` int(11) NOT NULL COMMENT 'المعرف الفريد والآلي لمركز التكلفة (المفتاح الأساسي)',
  `cost_centers_parent_id` int(11) NOT NULL DEFAULT '0' COMMENT 'الترتيب الثاني: يربط بمركز التكلفة الأعلى، يأخذ القيمة 0 إذا كان مركزاً رئيسياً علوياً، ويأخذ رقم المعرف المرجعي (id) إذا كان فرعاً تابعاً لمركز آخر',
  `cost_centers_code` varchar(50) NOT NULL COMMENT 'كود مركز التكلفة المحاسبي الفريد الذي يضعه المستخدم يدوياً لسهولة البحث والاستدعاء المالي',
  `cost_centers_name` varchar(150) NOT NULL COMMENT 'اسم مركز التكلفة بالكامل (مثل: الفروع، فرع الرياض، قسم التعبئة)',
  `cost_centers_allow_transactions` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'سؤال منطقي: هل يقبل المركز ربط العمليات والتكاليف؟ 1 (نعم/مركز فرعي تنفيذي)، 0 (لا/مركز رئيسي تجميعي يُمنع ربطه بالعمليات)',
  `cost_centers_is_active` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'حالة مركز التكلفة في النظام: 1 نشط ومتاح، 0 موقف لمنع ربط تكاليف جديدة عليه',
  `cost_centers_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت إنشاء مركز التكلفة مخزن كرقم صحيح (Unix Timestamp 64-bit) لتفادي كافة مشاكل التوقيت والمستقبل'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول مراكز التكلفة الهرمي';

-- --------------------------------------------------------

--
-- بنية الجدول `cost_items`
--

CREATE TABLE `cost_items` (
  `cost_items_id` int(11) NOT NULL COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي لسجل ربط التقرير بمركز التكلفة',
  `cost_items_cost_centers_id` int(11) NOT NULL COMMENT 'ربط برمجي مع معرف جدول مراكز التكلفة الهرمي الحالي',
  `cost_items_reports_files_id` int(11) NOT NULL COMMENT 'ربط برمجي مع معرف جدول ملفات التقارير الجاهزة المستقلة (reports_files_id)',
  `cost_items_parameters_values` json DEFAULT NULL COMMENT 'حفظ قيم المدخلات التي حددها المستخدم بصيغة JSON (مثال: {"parameters_user_id":7, "parameters_branch_id":2})',
  `cost_items_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت إنشاء سجل الربط مخزن كـ Unix Timestamp رقمي 64 بت'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول تسكين وتعيين ملفات التقارير الجاهزة داخل حاويات مراكز التكلفة بحقول JSON';

-- --------------------------------------------------------

--
-- بنية الجدول `invoices`
--

CREATE TABLE `invoices` (
  `invoices_id` int(11) NOT NULL COMMENT 'المعرف الفريد والآلي للفاتورة (المفتاح الأساسي)',
  `invoices_type` enum('sales','sales_return','sales_suspended','purchase','purchase_return','purchase_suspended','transfer','disposal','balance_adjustment','offer_price') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'انواع الفواتير مبيعات , مرتجع مبيعات , مشتريات , مرتجع مشتريات , مبيعات معلقة , مشتريات معلقة , تحويل , اتلاف , تسوية أرصدة',
  `invoices_payment_type` enum('cash','credit') NOT NULL DEFAULT 'cash' COMMENT 'نوع طريقة دفع الفاتورة: cash نقداً، credit آجل بالاتفاق',
  `invoices_chart_of_accounts_id` int(11) NOT NULL COMMENT 'رقم الحساب المالي المرتبط بالفاتورة من دليل الحسابات (يمثل حساب الصندوق/الخزينة في النقدي، أو حساب العميل/المورد في الآجل)',
  `invoices_discount_amount` decimal(15,4) NOT NULL DEFAULT '0.0000' COMMENT 'قيمة الحسم أو الخصم المالي الإجمالي المطبق على كامل ترويسة الفاتورة',
  `invoices_net_amount_exclud_tax` decimal(15,4) NOT NULL COMMENT 'اجمالي قيمة الفاتورة بعد الحسم وبدون ضرائب',
  `invoices_net_amount` decimal(15,4) NOT NULL DEFAULT '0.0000' COMMENT 'صافي القيمة المالية الإجمالية للفاتورة بالكامل بعد الخصومات وإضافة الضرائب',
  `invoices_tax_amount` decimal(15,4) NOT NULL DEFAULT '0.0000' COMMENT 'إجمالي قيمة ضريبة القيمة المضافة المحتسبة على كامل الفاتورة',
  `invoices_is_active` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'حالة الفاتورة في النظام: 1 نشطة ومعتمدة، 0 ملغاة',
  `invoices_notes` text COMMENT 'ملاحظات عامة على الفاتورة',
  `invoices_creator_member_id` int(11) DEFAULT NULL COMMENT 'معرف العضو منشيء الفاتورة',
  `invoices_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت إنشاء الفاتورة مخزن كـ Unix Timestamp رقمي 64 بت لتفادي مشاكل عام 2038'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول ترويسة الفاتورة';

-- --------------------------------------------------------

--
-- بنية الجدول `invoices_items`
--

CREATE TABLE `invoices_items` (
  `invoices_items_id` int(11) NOT NULL COMMENT 'المعرف الفريد والآلي لبند الفاتورة (المفتاح الأساسي)',
  `invoices_items_invoice_id` int(11) NOT NULL COMMENT 'الترتيب الثاني: الربط بجدول ترويسة الفاتورة الأب لتوثيق تبعية البند للمستند الأصلي',
  `invoices_items_movement_type` enum('sales','sales_return','sales_suspended','purchase','purchase_return','purchase_suspended','transfer_from','transfer_to','disposal','balance_adjustment','offer_price') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'نوع الحركة مبيعات , مرتجع مبيعات , مشتريات , مرتجع مشتريات , مبيعات معلقة , مشتريات معلقة , تحويل من , تحويل الى , اتلاف , تسوية أرصدة',
  `invoices_items_linked_id` int(11) DEFAULT NULL COMMENT 'رقم الحركة المقابلة والمرتبطة بها لحالات التحويل لربط الصفين ببعضهما البعض وحمايتها عند الحذف',
  `invoices_items_items_id` int(11) NOT NULL COMMENT 'رقم الصنف المرتبط من جدول الأصناف الرئيسي لمعرفة المادة المتحركة مخزنياً',
  `invoices_items_type` enum('standard','service','composite') NOT NULL DEFAULT 'standard' COMMENT 'نوع الصنف والأنواع التي تؤثر في الرصيد هي من نوع standard فقط والمكونات توضع انواعها ان كانت standard,service',
  `invoices_items_main_section_id` int(11) NOT NULL DEFAULT '0' COMMENT 'اذا كانت هذه الحركة بند مكون يذكر رقم ال id للصنف اللي يسمع في الرصيد البند العادي والبند المكون العادي فقط',
  `invoices_items_branches_warehouses_id` int(11) NOT NULL COMMENT 'رقم معرف المستودع الذي حصلت عليه الحركة',
  `invoices_items_units_id` int(11) NOT NULL COMMENT 'رقم وحدة القياس المختارة والمستخدمة في هذا السطر من جدول الوحدات لتحديد التكلفة والسعر',
  `invoices_items_quantity` decimal(12,4) NOT NULL COMMENT 'الكمية الفعالية المدخلة بالوحدة المختارة في سطر الفاتورة (مثل 2 كرتون)',
  `invoices_items_quantity_converted` decimal(12,4) NOT NULL COMMENT 'الكمية الفعلية بعد التحويل لأصغر وحدة (تخزن بالسالب للمبيعات والمحول منه ومرتجع المشتريات والإتلاف، وبالموجب للمشتريات ومرتجع المبيعات والمحول إليه)',
  `invoices_items_unit_price` decimal(15,4) NOT NULL DEFAULT '0.0000' COMMENT 'سعر شراء أو بيع الوحدة الواحدة في هذا السطر الفردي من الفاتورة قبل الضريبة',
  `invoices_items_total_price` decimal(15,4) NOT NULL DEFAULT '0.0000' COMMENT 'إجمالي قيمة السطر المالي المحتسب (الكمية الفعالية ضرب سعر الوحدة المحدد)',
  `invoices_items_expiration_date` bigint(20) DEFAULT NULL COMMENT 'تاريخ انتهاء صلاحية الشحنة المدخل في المشتريات بختم يونكس',
  `invoices_items_is_expiry_active` enum('Yes','No') DEFAULT NULL COMMENT 'هل الشحنة بهذا التاريخ لا تزال متوفرة؟ نعم تلقائياً حتى تنتهي',
  `invoices_items_notes` text COMMENT 'ملاحظات على سطر البند',
  `invoices_items_created_unix_time` bigint(20) NOT NULL COMMENT 'تاريخ وقت قيد وإدخال الحركة الفعلي بختم يونكس - يتولد آلياً حارس للأمان'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول بنود الفاتورة';

-- --------------------------------------------------------

--
-- بنية الجدول `items`
--

CREATE TABLE `items` (
  `items_id` int(11) NOT NULL COMMENT 'المعرف الآلي الفريد للصنف',
  `items_user_code` varchar(50) DEFAULT NULL COMMENT 'كود الصنف المحاسبي',
  `items_name` varchar(255) DEFAULT NULL COMMENT 'اسم الصنف التجاري',
  `items_type` enum('standard','service','composite') DEFAULT NULL COMMENT 'نوع الصنف: عادي، خدمة، مجمع',
  `items_cost_price` decimal(15,4) DEFAULT NULL COMMENT 'متوسط سعر التكلفة - يحسب آليا',
  `items_last_purchase_price` decimal(15,4) DEFAULT NULL COMMENT 'آخر سعر شراء للصنف - يحسب آليا',
  `items_total_stock` decimal(15,4) DEFAULT NULL COMMENT 'إجمالي الرصيد المخزني الحالي - يحسب آليا',
  `items_min_margin` decimal(5,2) DEFAULT NULL COMMENT 'أقل هامش ربح مئوي مقبول',
  `items_allow_decimal` tinyint(1) DEFAULT NULL COMMENT 'السماح بالكسور العشرية: 1 نعم، 0 لا',
  `items_is_active` tinyint(1) DEFAULT NULL COMMENT 'حالة الصنف: 1 نشط، 0 موقوف',
  `items_created_at` bigint(20) DEFAULT NULL COMMENT 'طابع وقت الإنشاء الرقمي Unix Timestamp'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول دليل الأصناف';

-- --------------------------------------------------------

--
-- بنية الجدول `items_components`
--

CREATE TABLE `items_components` (
  `items_components_id` int(11) NOT NULL COMMENT 'المعرف الآلي الفريد للبند المكون',
  `items_components_item_id` int(11) DEFAULT NULL COMMENT 'رقم الصنف المركب',
  `items_components_units_id` int(11) DEFAULT NULL COMMENT 'رقم وحدة الصنف',
  `items_components_component_items_id` int(11) NOT NULL COMMENT 'رقم معرف البند',
  `items_components_component_units_id` int(11) NOT NULL COMMENT 'رقم وحدة البند',
  `items_components_component_quantity` decimal(12,4) DEFAULT NULL COMMENT 'الكمية بالوحدة المحددة للبند'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول بنود ومكونات الأصناف المجمعة';

-- --------------------------------------------------------

--
-- بنية الجدول `journal_entries`
--

CREATE TABLE `journal_entries` (
  `journal_entries_id` int(11) NOT NULL COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي للقيد ورقم السجل الدفتري العام',
  `journal_entries_source_type` enum('manual','invoice','voucher') NOT NULL DEFAULT 'manual' COMMENT 'الترتيب الثاني: نوع المستند الأصلي المصدر (manual قيد يدوي، invoice قيد فاتورة، voucher قيد سند)',
  `journal_entries_source_id` int(11) NOT NULL DEFAULT '0' COMMENT 'رقم المعرف الفريد (ID) للمستند الأصلي التابع له (يأخذ رقم الفاتورة أو السند، ويأخذ 0 إذا كان القيد يدوياً صرفاً)',
  `journal_entries_date` bigint(20) NOT NULL COMMENT 'التاريخ المحاسبي الفعلي لاعتماد القيد في الدفاتر مخزن كـ Unix Timestamp رقمي 64 بت لتسهيل تقارير الجرد المالي والتكلفة',
  `journal_entries_description` text COMMENT 'البيان المحاسبي العام أو الشرح الإجمالي الذي يوضح سبب ومضمون القيد المالي الكلي',
  `journal_entries_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت إنشاء وتدوين السجل على السيرفر مخزن كـ Unix Timestamp 64 بت تفادياً لمشاكل عام 2038'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول ترويسة القيد';

-- --------------------------------------------------------

--
-- بنية الجدول `journal_items`
--

CREATE TABLE `journal_items` (
  `journal_items_id` int(11) NOT NULL COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي لسطر وبند القيد المحاسبي',
  `journal_items_journal_entries_id` int(11) NOT NULL COMMENT 'الترتيب الثاني: حقل الربط بترويسة القيد الأب ويبدأ بسابقة الجدول الحالية ومدمج به اسم الحقل الأصلي للربط المرجعي',
  `journal_items_chart_of_accounts_id` int(11) NOT NULL COMMENT 'حقل الربط بدليل الحسابات ويبدأ بسابقة الجدول الحالية ومدمج به اسم الحقل الأصلي لربط الحساب الفرعي التنفيذي',
  `journal_items_entry_type` enum('debit','credit') NOT NULL COMMENT 'طبيعة ونوع الطرف المالي في هذا السطر الفردي: debit مدين، credit دائن',
  `journal_items_amount` decimal(15,4) NOT NULL DEFAULT '0.0000' COMMENT 'المبلغ المالي الفعلي الخاص بهذا السطر بقيمة دقيقة تمنع فروقات الكسور العشرية في المعالجة المحاسبية',
  `journal_items_description` text COMMENT 'البيان التفصيلي أو الشرح الخاص بهذا السطر من القيد لشرح الحركة الفردية للحساب',
  `journal_items_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت إنشاء وتدوين بند القيد مخزن كـ Unix Timestamp رقمي 64 بت لتفادي مشاكل عام 2038'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول بنود القيد';

-- --------------------------------------------------------

--
-- بنية الجدول `reports_files`
--

CREATE TABLE `reports_files` (
  `reports_files_id` int(11) NOT NULL COMMENT 'المعرف الفريد والآلي لملف التقرير',
  `reports_files_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم التقرير الظاهر للمستخدم في لوحة التحكم',
  `reports_files_file_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم ملف الـ PHP الفعلي المستدعى خلفياً بالموديول',
  `reports_files_is_active` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'حالة تنشيط التقرير في النظام: 1 نشط، 0 معطل'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول تعريف موديولات وملفات التقارير المحاسبية المستقلة بالنظام';

-- --------------------------------------------------------

--
-- بنية الجدول `reports_parameters`
--

CREATE TABLE `reports_parameters` (
  `parameters_id` int(11) NOT NULL COMMENT 'المعرف الفريد والآلي لبند البرامتر',
  `parameters_reports_files_id` int(11) NOT NULL COMMENT 'ربط برمجي مع معرف جدول ملفات التقارير بدون قيد خارجي لتسهيل التعامل والسرعة',
  `parameters_key` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم الحقل البرمجي بالبادئة ويفهم النظام نوع المدخل من مسمى الحقل',
  `parameters_label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الاسم التوضيحي للحقل الظاهر للمستخدم عند تعبئة خيارات التقرير'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول شروط ومدخلات التقارير الديناميكية المعتمدة على بادئة التسمية';

-- --------------------------------------------------------

--
-- بنية الجدول `serial_numbers`
--

CREATE TABLE `serial_numbers` (
  `serial_numbers_id` int(11) NOT NULL COMMENT 'المفتاح الأساسي',
  `serial_numbers_invoices_id` int(11) NOT NULL COMMENT 'رقم ترويسة الفاتورة المرتبط',
  `serial_numbers_invoice_type` enum('sales','sales_return','sales_suspended','purchase','purchase_return','purchase_suspended','transfer') NOT NULL COMMENT 'نوع الفاتورة التابع لها السيريال',
  `serial_numbers_value` varchar(200) NOT NULL COMMENT 'قيمة السيريال نمبر المطبوع على الجهاز',
  `serial_numbers_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت إدراج السيريال بختم يونكس'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول الأرقام التسلسلية للقطع والأجهزة لتتبع سريان الضمان';

-- --------------------------------------------------------

--
-- بنية الجدول `texts_lang`
--

CREATE TABLE `texts_lang` (
  `texts_lang_id` int(10) UNSIGNED NOT NULL COMMENT 'المعرف الرقمي الفريد للنص ويبدأ تلقائياً من الرقم 1',
  `texts_lang_locale` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'نوع ورمز اللغة التي يتبع لها النص مثل (ar) أو (en)',
  `texts_lang_search_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'كلمة البحث المفتاحية داخل القالب مثل (txt_shipment_details)',
  `texts_lang_replacement_text` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'النص البديل والترجمة الفعلية التي ستوضع بدلاً من كلمة البحث'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول لغات ونصوص النظام';

-- --------------------------------------------------------

--
-- بنية الجدول `units`
--

CREATE TABLE `units` (
  `units_id` int(11) NOT NULL COMMENT 'المعرف الآلي الفريد للوحدة',
  `units_items_id` int(11) DEFAULT NULL COMMENT 'رقم الصنف المرتبط بالوحدة',
  `units_name` varchar(50) DEFAULT NULL COMMENT 'اسم الوحدة (حبة، كرتون...)',
  `units_barcode` varchar(100) DEFAULT NULL COMMENT 'باركود الوحدة الفرعي',
  `units_conversion_factor` decimal(12,4) DEFAULT NULL COMMENT 'معامل التحويل للوحدة الأصغر',
  `units_sale_price` decimal(15,4) DEFAULT NULL COMMENT 'سعر البيع الخاص بهذه الوحدة',
  `units_is_purchase_default` tinyint(1) DEFAULT NULL COMMENT 'الافتراضية للشراء: 1 نعم، 0 لا',
  `units_is_sale_default` tinyint(1) DEFAULT NULL COMMENT 'الافتراضية للبيع: 1 نعم، 0 لا',
  `units_is_transfer_default` tinyint(1) DEFAULT NULL COMMENT 'الافتراضية للتحويل: 1 نعم، 0 لا',
  `units_is_report_default` tinyint(1) DEFAULT NULL COMMENT 'الافتراضية للتقارير والجرد: 1 نعم، 0 لا',
  `units_is_active` tinyint(1) DEFAULT NULL COMMENT 'حالة الوحدة: 1 نشطة، 0 موقوفة',
  `units_created_at` bigint(20) DEFAULT NULL COMMENT 'طابع وقت الإنشاء الرقمي Unix Timestamp'
) ;

-- --------------------------------------------------------

--
-- بنية الجدول `users`
--

CREATE TABLE `users` (
  `users_id` int(11) NOT NULL COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي للمستخدم أو الموظف في النظام',
  `users_username` varchar(50) NOT NULL COMMENT 'اسم المستخدم الفريد المستخدم لتسجيل الدخول إلى النظام (مثل: ahmad_accountant)',
  `users_password_hash` varchar(255) NOT NULL COMMENT 'نص كلمة المرور المشفر والمحمي بآليات التشفير الأمنية الصارمة لمنع الاختراق',
  `users_full_name` varchar(150) NOT NULL COMMENT 'الاسم الكامل والمزدوج للموظف أو المحاسب لعرضه في التقارير المطبوعة وفواتير البيع والشراء',
  `users_role` enum('admin','manager','accountant','cashier') NOT NULL DEFAULT 'accountant' COMMENT 'رتبة وصلاحية المستخدم التشغيلية: admin مشرف، manager مدير، accountant محاسب، cashier كاشير/بائع',
  `users_is_active` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'حالة حساب المستخدم في النظام: 1 نشط ويسمح له بالدخول، 0 معطل وموقوف لمنع وصوله الفوري',
  `users_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت إنشاء حساب المستخدم مخزن كـ Unix Timestamp رقمي 64 بت لتفادي كافة مشاكل التوقيت ومستقبل عام 2038',
  `users_last_login_unix_time` bigint(20) NOT NULL COMMENT 'وقت اخر تسجيل دخول'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول المستخدمين';

-- --------------------------------------------------------

--
-- بنية الجدول `user_activities`
--

CREATE TABLE `user_activities` (
  `user_activities_id` int(11) NOT NULL COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي لسجل الحدث والرقابة (Audit Trail)',
  `users_id` int(11) NOT NULL COMMENT 'الترتيب الثاني: رقم المعرف الفريد للمستخدم الذي قام بالحدث، متطابق 100% وبنفس التسمية المسجلة في جدول المستخدمين لتوثيق التبعية الصارمة',
  `user_activities_action` varchar(50) NOT NULL COMMENT 'نوع الإجراء أو الحدث المتخذ في النظام (مثل: login، create_invoice، update_cost، delete_journal_item)',
  `user_activities_table_name` varchar(50) NOT NULL COMMENT 'اسم الجدول في قاعدة البيانات الذي تأثر بالحدث (مثل: invoices، chart_of_accounts، items) لسهولة التتبع الفني في الخلفية',
  `user_activities_record_id` int(11) NOT NULL DEFAULT '0' COMMENT 'رقم المعرف الفريد (ID) للسجل الذي تأثر بالحدث داخل الجدول المذكور أعلاه (ويأخذ 0 في أحداث الدخول والخروج)',
  `user_activities_details` text COMMENT 'تفاصيل معقدة أو نص يوضح ما تم تغييره (مثل تخزين قيم الحقول القديمة والجديدة بصيغة JSON لمراجعة فروقات التعديل)',
  `user_activities_ip_address` varchar(45) DEFAULT NULL COMMENT 'عنوان بروتوكول الإنترنت (IP Address) للجهاز الذي نفذ الموظف من خلاله الحركة لمتابعة النطاق الأمني',
  `user_activities_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت حدوث الفعل الفوري على السيرفر مخزن كـ Unix Timestamp رقمي صحيح 64 بت تفادياً لمشاكل عام 2038'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول أحداث المستخدمين';

-- --------------------------------------------------------

--
-- بنية الجدول `user_settings`
--

CREATE TABLE `user_settings` (
  `user_settings_id` int(11) NOT NULL COMMENT 'المعرف الفريد والآلي لرقم السجل الخاص بتفضيلات المستخدم',
  `user_settings_user_id` int(11) NOT NULL COMMENT 'الترتيب الثاني: رقم المستخدم أو الموظف المرتبط به هذا التفضيل الشخصي لربطه بملفه',
  `user_settings_key` varchar(100) NOT NULL COMMENT 'الاسم البرمجي للتفضيل باللغة الإنجليزية (مثال: default_invoice_input_mode أو hide_fields)',
  `user_settings_value` text NOT NULL COMMENT 'قيمة التفضيل أو الاختيارات الشخصية مخزنة كنص طويل (أو مصفوفة تفضيلية)',
  `user_settings_description` text NOT NULL COMMENT 'نبذة توضيحية باللغة العربية تشرح دور هذا التفضيل في تسهيل عمل الموظف اليومي',
  `user_settings_updated_at` bigint(20) NOT NULL COMMENT 'طابع وقت يونكس الرقمي (Unix Timestamp 64-bit) لآخر تحديث لتفضيلات المستخدم'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول إعدادات وتفضيلات المستخدم';

-- --------------------------------------------------------

--
-- بنية الجدول `vouchers`
--

CREATE TABLE `vouchers` (
  `vouchers_id` int(11) NOT NULL COMMENT 'المعرف الفريد والآلي للسند (المفتاح الأساسي ورقم السند الدفتري)',
  `vouchers_debit_account_id` int(11) NOT NULL COMMENT 'الترتيب الثاني: رقم حساب الطرف المدين من دليل الحسابات (مثل: حساب الصندوق في سند القبض المستلم)',
  `vouchers_credit_account_id` int(11) NOT NULL COMMENT 'رقم حساب الطرف الدائن من دليل الحسابات (مثل: حساب العميل في سند القبض، أو حساب البنك في سند الصرف)',
  `vouchers_type` enum('receipt','payment','receipt_suspended','payment_suspended') NOT NULL COMMENT 'نوع السند: قبض، صرف، قبض معلق، صرف معلق',
  `vouchers_amount` decimal(15,4) NOT NULL DEFAULT '0.0000' COMMENT 'إجمالي القيمة المالية للسند بالكامل قبل توزيع البنود',
  `vouchers_description` text COMMENT 'البيان أو الشرح العام للسند الموضح لسبب القبض أو الصرف الجماعي',
  `vouchers_is_active` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'حالة السند في النظام: 1 نشط ومعتمد محاسبياً، 0 ملغى ومحذوف أثره ماليًا',
  `vouchers_created_at` bigint(20) NOT NULL COMMENT 'تاريخ ووقت إنشاء السند مخزن كـ Unix Timestamp رقمي 64 بت لتفادي مشاكل المستقبل وعام 2038'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='جدول ترويسة السند';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_settings`
--
ALTER TABLE `admin_settings`
  ADD PRIMARY KEY (`admin_settings_id`),
  ADD UNIQUE KEY `admin_settings_key` (`admin_settings_key`);

--
-- Indexes for table `asset_depreciations`
--
ALTER TABLE `asset_depreciations`
  ADD PRIMARY KEY (`asset_depreciations_id`),
  ADD KEY `asset_depreciations_chart_of_accounts_id` (`asset_depreciations_chart_of_accounts_id`);

--
-- Indexes for table `attachments`
--
ALTER TABLE `attachments`
  ADD PRIMARY KEY (`attachments_id`);

--
-- Indexes for table `branches_warehouses`
--
ALTER TABLE `branches_warehouses`
  ADD PRIMARY KEY (`branches_warehouses_id`),
  ADD UNIQUE KEY `branches_warehouses_code` (`branches_warehouses_code`);

--
-- Indexes for table `chart_of_accounts`
--
ALTER TABLE `chart_of_accounts`
  ADD PRIMARY KEY (`chart_of_accounts_id`),
  ADD UNIQUE KEY `chart_of_accounts_code` (`chart_of_accounts_code`);

--
-- Indexes for table `cost_centers`
--
ALTER TABLE `cost_centers`
  ADD PRIMARY KEY (`cost_centers_id`),
  ADD UNIQUE KEY `cost_centers_code` (`cost_centers_code`);

--
-- Indexes for table `cost_items`
--
ALTER TABLE `cost_items`
  ADD PRIMARY KEY (`cost_items_id`),
  ADD KEY `idx_cost_items_center` (`cost_items_cost_centers_id`) COMMENT 'فهرس لتسريع جلب التقارير التابعة لمركز تكلفة معين',
  ADD KEY `idx_cost_items_report` (`cost_items_reports_files_id`) COMMENT 'فهرس لتسريع البحث وعمليات الربط البرمجية للملفات';

--
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`invoices_id`),
  ADD KEY `invoices_chart_of_accounts_id` (`invoices_chart_of_accounts_id`);

--
-- Indexes for table `invoices_items`
--
ALTER TABLE `invoices_items`
  ADD PRIMARY KEY (`invoices_items_id`),
  ADD KEY `invoices_items_invoice_id` (`invoices_items_invoice_id`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`items_id`),
  ADD UNIQUE KEY `items_user_code` (`items_user_code`);

--
-- Indexes for table `items_components`
--
ALTER TABLE `items_components`
  ADD PRIMARY KEY (`items_components_id`),
  ADD KEY `items_components_item_id` (`items_components_item_id`),
  ADD KEY `items_components_units_id` (`items_components_units_id`);

--
-- Indexes for table `journal_entries`
--
ALTER TABLE `journal_entries`
  ADD PRIMARY KEY (`journal_entries_id`);

--
-- Indexes for table `journal_items`
--
ALTER TABLE `journal_items`
  ADD PRIMARY KEY (`journal_items_id`),
  ADD KEY `journal_items_journal_entries_id` (`journal_items_journal_entries_id`),
  ADD KEY `journal_items_chart_of_accounts_id` (`journal_items_chart_of_accounts_id`);

--
-- Indexes for table `reports_files`
--
ALTER TABLE `reports_files`
  ADD PRIMARY KEY (`reports_files_id`);

--
-- Indexes for table `reports_parameters`
--
ALTER TABLE `reports_parameters`
  ADD PRIMARY KEY (`parameters_id`),
  ADD KEY `idx_parameters_reports_files` (`parameters_reports_files_id`) COMMENT 'فهرس عادي لتسريع عمليات الاستعلام والبحث البرمجي عن البرامترات';

--
-- Indexes for table `serial_numbers`
--
ALTER TABLE `serial_numbers`
  ADD PRIMARY KEY (`serial_numbers_id`),
  ADD UNIQUE KEY `serial_numbers_value` (`serial_numbers_value`),
  ADD KEY `serial_numbers_invoices_id` (`serial_numbers_invoices_id`);

--
-- Indexes for table `texts_lang`
--
ALTER TABLE `texts_lang`
  ADD PRIMARY KEY (`texts_lang_id`),
  ADD UNIQUE KEY `unique_translation` (`texts_lang_locale`,`texts_lang_search_key`);

--
-- Indexes for table `units`
--
ALTER TABLE `units`
  ADD PRIMARY KEY (`units_id`),
  ADD UNIQUE KEY `uq_units_barcode` (`units_barcode`),
  ADD UNIQUE KEY `units_items_id` (`units_items_id`,`units_conversion_factor`),
  ADD UNIQUE KEY `idx_unique_purchase_default` (`end`(1));

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`users_id`),
  ADD UNIQUE KEY `users_username` (`users_username`);

--
-- Indexes for table `user_activities`
--
ALTER TABLE `user_activities`
  ADD PRIMARY KEY (`user_activities_id`),
  ADD KEY `users_id` (`users_id`);

--
-- Indexes for table `user_settings`
--
ALTER TABLE `user_settings`
  ADD PRIMARY KEY (`user_settings_id`),
  ADD UNIQUE KEY `uq_user_key` (`user_settings_user_id`,`user_settings_key`) COMMENT 'مفتاح مركب فريد يمنع تكرار نفس مفتاح الإعداد لنفس المستخدم';

--
-- Indexes for table `vouchers`
--
ALTER TABLE `vouchers`
  ADD PRIMARY KEY (`vouchers_id`),
  ADD KEY `vouchers_debit_account_id` (`vouchers_debit_account_id`),
  ADD KEY `vouchers_credit_account_id` (`vouchers_credit_account_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_settings`
--
ALTER TABLE `admin_settings`
  MODIFY `admin_settings_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الفريد والآلي لرقم الصلاحية أو القيد العام';

--
-- AUTO_INCREMENT for table `asset_depreciations`
--
ALTER TABLE `asset_depreciations`
  MODIFY `asset_depreciations_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي لسجل إهلاك الأصل الثابت';

--
-- AUTO_INCREMENT for table `attachments`
--
ALTER TABLE `attachments`
  MODIFY `attachments_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي لسجل المرفق الرقمي';

--
-- AUTO_INCREMENT for table `branches_warehouses`
--
ALTER TABLE `branches_warehouses`
  MODIFY `branches_warehouses_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الفريد والآلي للسجل (المفتاح الأساسي)';

--
-- AUTO_INCREMENT for table `chart_of_accounts`
--
ALTER TABLE `chart_of_accounts`
  MODIFY `chart_of_accounts_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الفريد والآلي للحساب (المفتاح الأساسي)';

--
-- AUTO_INCREMENT for table `cost_centers`
--
ALTER TABLE `cost_centers`
  MODIFY `cost_centers_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الفريد والآلي لمركز التكلفة (المفتاح الأساسي)';

--
-- AUTO_INCREMENT for table `cost_items`
--
ALTER TABLE `cost_items`
  MODIFY `cost_items_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي لسجل ربط التقرير بمركز التكلفة';

--
-- AUTO_INCREMENT for table `invoices`
--
ALTER TABLE `invoices`
  MODIFY `invoices_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الفريد والآلي للفاتورة (المفتاح الأساسي)';

--
-- AUTO_INCREMENT for table `invoices_items`
--
ALTER TABLE `invoices_items`
  MODIFY `invoices_items_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الفريد والآلي لبند الفاتورة (المفتاح الأساسي)';

--
-- AUTO_INCREMENT for table `items`
--
ALTER TABLE `items`
  MODIFY `items_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الآلي الفريد للصنف';

--
-- AUTO_INCREMENT for table `items_components`
--
ALTER TABLE `items_components`
  MODIFY `items_components_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الآلي الفريد للبند المكون';

--
-- AUTO_INCREMENT for table `journal_entries`
--
ALTER TABLE `journal_entries`
  MODIFY `journal_entries_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي للقيد ورقم السجل الدفتري العام';

--
-- AUTO_INCREMENT for table `journal_items`
--
ALTER TABLE `journal_items`
  MODIFY `journal_items_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي لسطر وبند القيد المحاسبي';

--
-- AUTO_INCREMENT for table `reports_files`
--
ALTER TABLE `reports_files`
  MODIFY `reports_files_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الفريد والآلي لملف التقرير';

--
-- AUTO_INCREMENT for table `reports_parameters`
--
ALTER TABLE `reports_parameters`
  MODIFY `parameters_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الفريد والآلي لبند البرامتر';

--
-- AUTO_INCREMENT for table `serial_numbers`
--
ALTER TABLE `serial_numbers`
  MODIFY `serial_numbers_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المفتاح الأساسي';

--
-- AUTO_INCREMENT for table `texts_lang`
--
ALTER TABLE `texts_lang`
  MODIFY `texts_lang_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'المعرف الرقمي الفريد للنص ويبدأ تلقائياً من الرقم 1';

--
-- AUTO_INCREMENT for table `units`
--
ALTER TABLE `units`
  MODIFY `units_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الآلي الفريد للوحدة';

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `users_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي للمستخدم أو الموظف في النظام';

--
-- AUTO_INCREMENT for table `user_activities`
--
ALTER TABLE `user_activities`
  MODIFY `user_activities_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المفتاح الأساسي: المعرف الفريد والآلي لسجل الحدث والرقابة (Audit Trail)';

--
-- AUTO_INCREMENT for table `user_settings`
--
ALTER TABLE `user_settings`
  MODIFY `user_settings_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الفريد والآلي لرقم السجل الخاص بتفضيلات المستخدم';

--
-- AUTO_INCREMENT for table `vouchers`
--
ALTER TABLE `vouchers`
  MODIFY `vouchers_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'المعرف الفريد والآلي للسند (المفتاح الأساسي ورقم السند الدفتري)';

--
-- قيود الجداول المحفوظة
--

--
-- القيود للجدول `serial_numbers`
--
ALTER TABLE `serial_numbers`
  ADD CONSTRAINT `serial_numbers_ibfk_1` FOREIGN KEY (`serial_numbers_invoices_id`) REFERENCES `invoices` (`invoices_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
