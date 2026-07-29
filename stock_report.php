<?php
/**
 * الأدوية الخاضعه للرقابة بمستشفى الصحة النفسية بالطائف
 * لوحة جرد الأرصدة المتقاطعة ومحرك كشف الحساب التاريخي للأصناف - النصف الأول
 */
require_once 'function.php'; 
require_once 'auth.php';     

$page_title = "الأدوية الخاضعه للرقابة بمستشفى الصحة النفسية بالطائف - لوحة الجرد والمصفوفة";
$current_page = $_SERVER['PHP_SELF'];
$current_year = date('Y');
$message = "";

$dynamic_warehouses_headers = "";
$matrix_rows_html = "";
$statement_account_area_html = "";

// 1. جلب قائمة كافة المستودعات المسجلة بالنظام لبناء أعمدة المصفوفة ديناميكياً
$warehouses_list = array();
$wh_res = mysql_query("SELECT `warehouse_id`, `warehouse_name` FROM `warehouses` ORDER BY `warehouse_id` ASC", $db);
while ($wh = mysql_fetch_assoc($wh_res)) {
    $warehouses_list[] = array('id' => intval($wh['warehouse_id']), 'name' => $wh['warehouse_name']);
    $dynamic_warehouses_headers .= '<th style="padding: 12px; border: 1px solid #cbd5e1; font-size:0.85rem; text-align:center;">' . htmlspecialchars($wh['warehouse_name']) . '</th>';
}

// 2. الدوران المركزي لجلب الأصناف الطبية وبناء خلايا الأرصدة والجبر الجيد (+ و -) لكل مستودع
$items_res = mysql_query("SELECT `item_id`, `item_medicine_name`, `item_dosage_name`, `item_batch_number` FROM `items` ORDER BY `item_id` DESC", $db);
$row_counter = 0;

while ($itm = mysql_fetch_assoc($items_res)) {
    $item_id   = intval($itm['item_id']);
    $item_name = htmlspecialchars($itm['item_medicine_name'] . " " . $itm['item_dosage_name'] . " [تشغيلة: " . $itm['item_batch_number'] . "]");
    $row_bg    = ($row_counter % 2 == 0) ? '#ffffff' : '#f8fafc';
    
    $warehouse_cells_html = "";
    $item_total_balance   = 0;
    
    // جلب ورصد حساب الرصيد الصافي الحالي للصنف داخل كل مستودع على حدة بدالة SUM الكاشفة لـ converted_quantity
    foreach ($warehouses_list as $wh_node) {
        $wh_id = $wh_node['id'];
        $bal_query = mysql_query("SELECT SUM(`movement_converted_quantity`) as balance FROM `item_movements` WHERE `movement_item_id` = $item_id AND `movement_warehouse_id` = $wh_id", $db);
        $bal_row = mysql_fetch_assoc($bal_query);
        $current_cell_balance = intval($bal_row['balance']);
        
        $item_total_balance += $current_cell_balance;
        
        // تنسيق خلية الرصيد بلون خفيف لسهولة القراءة الحركية
        $cell_style = ($current_cell_balance == 0) ? 'color: #94a3b8; font-weight: normal;' : 'color: #1e293b; font-weight: bold;';
        $warehouse_cells_html .= '<td style="padding: 12px; border: 1px solid #cbd5e1; text-align: center; ' . $cell_style . '">' . $current_cell_balance . '</td>';
    }
    
    // التحقق من تفعيل تنبيه الحد الأدنى لمخزون الصنف الكلي لتلوين السطر بالكامل بالأحمر عند النقص الحرج
    $limit_query = mysql_query("SELECT `limit_quantity` FROM `item_limits` WHERE `limit_item_id` = $item_id LIMIT 1", $db);
    if ($limit_query && mysql_num_rows($limit_query) > 0) {
        $limit_row = mysql_fetch_assoc($limit_query);
        if ($item_total_balance <= intval($limit_row['limit_quantity']) && $item_total_balance > 0) {
            $row_bg = '#fef2f2'; // إضاءة باللون الأحمر الخفيف كتنبيه رقابي حرج
        }
    }
    
    // إدراج السطر المكتمل للأرصدة المتقاطعة مع زر التقصي التاريخي لكشف الحساب
    $matrix_rows_html .= '
    <tr style="background-color: ' . $row_bg . ';">
        <td style="padding: 12px; border: 1px solid #cbd5e1; font-weight: bold; color: #334155;">' . $item_name . '</td>
        ' . $warehouse_cells_html . '
        <td style="padding: 12px; border: 1px solid #cbd5e1; text-align: center; font-weight: bold; color: white; background-color: #1e293b;">' . $item_total_balance . '</td>
        <td style="padding: 12px; border: 1px solid #cbd5e1; text-align: center; white-space: nowrap;">
            <a href="stock_report.php?view_statement_id=' . $item_id . '#statement_section" style="background-color: #0d9488; color: white; text-decoration: none; padding: 6px 14px; border-radius: 4px; font-weight: bold; font-size: 0.8rem; display: block; box-shadow: 0 2px 4px rgba(0,0,0,0.05); text-align: center;">معاينة كشف الحركة</a>
        </td>
    </tr>';
    $row_counter++;
}
// 3. [بناء محرك كشف الحساب البنكي التاريخي المفصل للصنف المختار بالأحدث أولاً]
if (isset($_GET['view_statement_id']) && intval($_GET['view_statement_id']) > 0) {
    $statement_item_id = intval($_GET['view_statement_id']);
    
    // جلب تفاصيل اسم الصنف لترويسة كشف الحساب
    $st_item_query = mysql_query("SELECT `item_medicine_name`, `item_dosage_name`, `item_batch_number` FROM `items` WHERE `item_id` = $statement_item_id LIMIT 1", $db);
    if ($st_item_query && mysql_num_rows($st_item_query) > 0) {
        $st_item_row = mysql_fetch_assoc($st_item_query);
        $statement_item_name = htmlspecialchars($st_item_row['item_medicine_name'] . " " . $st_item_row['item_dosage_name'] . " [تشغيلة: " . $st_item_row['item_batch_number'] . "]");
        
        // استخراج مسمى أصغر وحدة قياس فعلية لهذا الصنف (المعامل الخاص بها يساوي 1 حتماً)
        $smallest_unit_name = "وحدة";
        $u_name_q = mysql_query("SELECT `unit_name` FROM `item_units` WHERE `unit_item_id` = $statement_item_id AND `unit_conversion_factor` = 1 LIMIT 1", $db);
        if ($u_name_q && mysql_num_rows($u_name_q) > 0) {
            $u_name_data = mysql_fetch_assoc($u_name_q);
            $smallest_unit_name = htmlspecialchars($u_name_data['unit_name']);
        }

        // استعلام كشف الحساب التاريخي الصارم بالفرز العكسي (الأحدث أولاً بموجب movement_id DESC) ليكون آخر حدث في القمة
        $movements_query = "SELECT m.*, w.`warehouse_name`, u.`user_full_name`, un.`unit_name` as raw_unit_name
                            FROM `item_movements` m
                            LEFT JOIN `warehouses` w ON m.`movement_warehouse_id` = w.`warehouse_id`
                            LEFT JOIN `users` u ON m.`movement_user_id` = u.`user_id`
                            LEFT JOIN `item_units` un ON m.`movement_unit_id` = un.`unit_id`
                            WHERE m.`movement_item_id` = $statement_item_id
                            ORDER BY m.`movement_id` DESC";
        $movements_set = mysql_query($movements_query, $db);
        
        $statement_rows_html = "";
        $st_counter = 0;
        
        while ($move = mysql_fetch_assoc($movements_set)) {
            // [التصحيح والربط الرقابي الحاسم للوقت الحقيقي بالثانية]: الاعتماد على طابع الوقت الرقمي المجلوب حياً عبر الـ Trigger
            $m_date = (!empty($move['movement_created_unix_time']) && intval($move['movement_created_unix_time']) > 0) 
                      ? date('Y-m-d H:i:s', intval($move['movement_created_unix_time'])) 
                      : date('Y-m-d H:i:s', time()); 
            
            $m_type = $move['movement_type'];
            $m_qty  = intval($move['movement_quantity']);
            $m_conv = intval($move['movement_converted_quantity']);
            $m_wh   = htmlspecialchars($move['warehouse_name']);
            $m_user = htmlspecialchars($move['user_full_name']);
            $m_raw_unit = !empty($move['raw_unit_name']) ? htmlspecialchars($move['raw_unit_name']) : "وحدة";
            
            $type_text_ar = "";
            $doc_ref_text = "";
            $qty_style    = "";
            
            if ($m_type == 'prescription') {
                $type_text_ar = "📋 صرف وصفة طبية لمريض";
                $p_id = intval($move['movement_prescription_id']);
                $doc_ref_text = '<a href="edit_prescription.php?prescription_id=' . $p_id . '" style="color:#1e3a8a; font-weight:bold; text-decoration:underline;">وصفة #' . $p_id . '</a>';
                $qty_style = 'color: #ef4444; font-weight: bold;'; // أحمر سالبة للخصم
            } else if ($m_type == 'inbound') {
                $type_text_ar = "📦 توريد شحنة مشتريات (وارد)";
                $pur_id = intval($move['movement_reference_id']);
                $doc_ref_text = '<a href="edit_purchase.php?purchase_id=' . $pur_id . '" style="color:#0f766e; font-weight:bold; text-decoration:underline;">فاتورة وارد #' . $pur_id . '</a>';
                $qty_style = 'color: #10b981; font-weight: bold;'; // أخضر موجبة للإضافة
            } else if ($m_type == 'transfer_from') {
                $type_text_ar = "📤 تحويل صادر (من المستودع)";
                $trans_id = intval($move['movement_reference_id']);
                $doc_ref_text = '<a href="edit_transfer.php?transfer_invoice_number=' . $trans_id . '" style="color:#b45309; font-weight:bold; text-decoration:underline;">تحويل #' . $trans_id . '</a>';
                $qty_style = 'color: #ef4444; font-weight: bold;'; // أحمر سالبة للخصم
            } else if ($m_type == 'transfer_to') {
                $type_text_ar = "📥 تحويل وارد (إلى المستودع)";
                $trans_id = intval($move['movement_reference_id']);
                $doc_ref_text = '<a href="edit_transfer.php?transfer_invoice_number=' . $trans_id . '" style="color:#10b981; font-weight:bold; text-decoration:underline;">تحويل #' . $trans_id . '</a>';
                $qty_style = 'color: #10b981; font-weight: bold;'; // أخضر موجبة للإضافة
            }
            
            $sign = ($m_conv > 0) ? "+" : "";
            $row_st_bg = ($st_counter % 2 == 0) ? '#ffffff' : '#f8fafc';
            
            $statement_rows_html .= '
            <tr style="background-color: ' . $row_st_bg . '; text-align: center;">
                <td style="padding: 10px; border: 1px solid #cbd5e1; color: #475569; font-weight: bold;">' . $move['movement_id'] . '</td>
                <td style="padding: 10px; border: 1px solid #cbd5e1; text-align: right; font-weight: bold;">' . $type_text_ar . ' <br/><small style="color: #64748b; font-weight: normal; font-size: 0.75rem;">⏰ ' . $m_date . '</small></td>
                <td style="padding: 10px; border: 1px solid #cbd5e1; text-align: right; color: #334155;">' . $m_wh . '</td>
                <td style="padding: 10px; border: 1px solid #cbd5e1;">' . $doc_ref_text . '</td>
                <td style="padding: 10px; border: 1px solid #cbd5e1; color: #475569;">' . $m_qty . ' ' . $m_raw_unit . '</td>
                <td style="padding: 10px; border: 1px solid #cbd5e1; ' . $qty_style . '">' . $sign . $m_conv . ' ' . $smallest_unit_name . '</td>
                <td style="padding: 10px; border: 1px solid #cbd5e1; color: #64748b; font-size: 0.85rem;">' . $m_user . '</td>
            </tr>';
            $st_counter++;
        }
        
        if ($st_counter == 0) {
            $statement_rows_html = '<tr><td colspan="7" style="padding: 15px; text-align: center; color: #64748b; font-style: italic;">هذا الصنف الدوائي مفرغ كلياً ولا توجد عليه أي حركات مخزنية تاريخية مسجلة بالنظام حتى الآن!</td></tr>';
        }
        
        // بناء هيكل كشف الحساب البنكي الكامل في الأسفل
        $statement_account_area_html = '
        <div id="statement_section" style="margin-top: 40px; border: 2px solid #0d9488; padding: 25px; border-radius: 6px; background-color: #fff;">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #cbd5e1; padding-bottom: 10px; margin-bottom: 20px;">
                <h3 style="margin: 0; color: #0f766e; font-size: 1.2rem;">🧾 تفاصيل كشف الحركة الحسابي للصنف: <span style="color:#1e3a8a;">' . $statement_item_name . '</span></h3>
                <button onclick="window.print()" style="background-color: #64748b; color: white; border: none; padding: 6px 15px; border-radius: 4px; font-weight: bold; cursor: pointer; font-size:0.8rem;">🖨️ طباعة كشف الحركة</button>
            </div>
            <table style="width: 100%; border-collapse: collapse; font-size: 0.9rem;">
                <thead>
                    <tr style="background-color: #0f766e; color: white;">
                        <th style="padding: 10px; border: 1px solid #cbd5e1; width: 90px;">رقم القيد</th>
                        <th style="padding: 10px; border: 1px solid #cbd5e1; text-align: right; width: 220px;">نوع الإجراء اللوجستي ووقت القيد</th>
                        <th style="padding: 10px; border: 1px solid #cbd5e1; text-align: right;">المستودع / الصيدلية المتأثرة</th>
                        <th style="padding: 10px; border: 1px solid #cbd5e1; width: 140px;">المستند المرجعي</th>
                        <th style="padding: 10px; border: 1px solid #cbd5e1; width: 140px;">الكمية الخام المدخلة</th>
                        <th style="padding: 10px; border: 1px solid #cbd5e1; width: 150px;">الصافي المفرود لأصغر وحدة</th>
                        <th style="padding: 10px; border: 1px solid #cbd5e1; width: 180px;">الموظف المعتمد للإجراء</th>
                    </tr>
                </thead>
                <tbody>
                    ' . $statement_rows_html . '
                </tbody>
            </table>
        </div>';
    }
}

// 4. دمج الواجهة الكلية وتوليد المحتوى بالأسلوب الثلاثي المحمي الصافي للـ eval المانع لقضم الأزرار
$view_content = file_get_contents("templates/stock_report_view.html");
$view_content = str_replace('"', '\"', $view_content);
eval("\$view_content = \"$view_content\";");
$body = $view_content;

// 5. طباعة التقرير بداخل نطاق الهيكل الموحد لـ layout.html لحماية المظهر والتشفير العربي
$layout_content = file_get_contents("templates/layout.html");
$layout_content = str_replace('"', '\"', $layout_content);
eval("\$layout_content = \"$layout_content\";");

echo $layout_content;
?>
