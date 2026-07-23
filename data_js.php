<?php
// تفعيل ترويسة المتصفح ليفهم أن البيانات القادمة هي من نوع JSON بالترميز العالمي UTF-8
header('Content-Type: application/javascript; charset=utf-8');
require_once 'db.php';

$items_query = "SELECT `item_id`,`item_medicine_name`,`item_dosage_name` FROM `items`  ORDER BY `items`.`item_id` ASC";
$items_result = mysql_query($items_query, $db);
if ($items_result) {
    echo "const itemsArray = new Array();\n";
    echo "const itemsUArray = new Array();\n";
    while ($row = mysql_fetch_assoc($items_result)) {
        extract($row);
        echo "itemsArray[{$item_id}]='{$item_medicine_name} ({$item_dosage_name})';\n";
        $units_query = "SELECT `unit_id`,`unit_name`,`unit_conversion_factor` FROM `item_units`  WHERE `unit_item_id`=$item_id ORDER BY `unit_id` ASC";
        $units_result = mysql_query($units_query, $db);
        if ($units_result) {
            echo "itemsUArray[{$item_id}]=[];\n";
            while ($rowunits = mysql_fetch_assoc($units_result)) {
                extract($rowunits);
                echo"itemsUArray[{$item_id}][{$unit_id}]='{$unit_name} ({$unit_conversion_factor})';\n";
            }
        }
    }
}

/* 
   2. سحب مصفوفة المستودعات والمخازن من جدول `warehouses`
*/
$warehouse_query = "SELECT warehouse_id, warehouse_name FROM warehouses ORDER BY `warehouse_id` ASC";
$warehouse_result = mysql_query($warehouse_query, $db);

if ($warehouse_result) {
    echo "const warehouseArray = new Array();\n";
    while ($row = mysql_fetch_assoc($warehouse_result)) {
        extract($row);
        echo "warehouseArray[{$warehouse_id}]='{$warehouse_name}';\n";
    }
}
?>
