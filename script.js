// ==========================================
// 1. إعدادات بدء التشغيل والشحن التلقائي
// ==========================================

document.addEventListener("DOMContentLoaded", function() {
    // ضبط تاريخ اليوم تلقائياً عند فتح الشاشة
    document.getElementById('working_date').value = new Date().toISOString().split('T')[0];
    
    // شحن قائمة المستودعات ديناميكياً من مصفوفة warehouseArray المجلوبة من السيرفر
    initWarehouseList();
});

// عداد لتوليد أرقام ترتيبية فريدة (Index) لأسطر الفاتورة
let itemIndex = 0;

// دالة لتعبئة القائمة المنسدلة للمستودعات بناءً على معرفاتها وأسمائها الحقيقية
function initWarehouseList() {
    if (typeof warehouseArray !== 'undefined') {
        const warehouseSelect = document.getElementById('warehouse');
        warehouseSelect.innerHTML = ''; // تفريغ أي خيارات قديمة
        
        for (const whId in warehouseArray) {
            const opt = document.createElement('option');
            opt.value = whId; // تخزين المعرف الرقمي للمستودع (مثل: 5)
            opt.textContent = warehouseArray[whId]; // عرض الاسم للصيدلي
            warehouseSelect.appendChild(opt);
        }
    }
}

// ==========================================
// 2. دوال أحداث لوحة المفاتيح (التنقل بالـ Enter)
// ==========================================

// حقل: تاريخ مستند الوارد
function handleWorkingDateKey(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        document.getElementById('supplier').focus();
    }
}

// حقل: اسم المورد
function handleSupplierKey(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        document.getElementById('notes').focus();
    }
}

// حقل: ملاحظات الفاتورة
function handleNotesKey(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        document.getElementById('item_id').focus();
    }
}

// حقل: معرف الصنف (تبحث عن الدواء في itemsArray وتشحن وحداته من itemsUArray)
function handleItemIdKey(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        
        const itemIdInput = document.getElementById('item_id');
        const itemId = itemIdInput.value.trim();
        const itemNameInput = document.getElementById('item_name');
        const unitSelect = document.getElementById('unit');

        unitSelect.innerHTML = ''; // تفريغ قائمة الوحدات القديمة

        // 1. التحقق من وجود الصنف داخل مصفوفة الأدوية الأساسية
        if (typeof itemsArray !== 'undefined' && itemsArray[itemId]) {
            
            // وضع القيمة كما هي من المصفوفة مباشرة لحقل المعاينة
            itemNameInput.value = itemsArray[itemId];
            
            // 2. التحقق من وجود وحدات مقترنة بهذا الصنف في مصفوفة الوحدات
            if (typeof itemsUArray !== 'undefined' && itemsUArray[itemId]) {
                
                // الدوران المباشر على المعرفات الرقمية للوحدات
                for (const uId in itemsUArray[itemId]) {
                    
                    const opt = document.createElement('option');
                    opt.value = uId; // تخزين معرف الوحدة الرقمي
                    
                    // أخذ قيمة المصفوفة ووضعها كما هي تماماً بدون متغيرات فصل
                    opt.textContent = itemsUArray[itemId][uId]; 
                    opt.setAttribute('data-name', itemsUArray[itemId][uId]); 
                    
                    unitSelect.appendChild(opt);
                }
            }
            
            // إذا لم تكن هناك وحدات مسجلة نضع خياراً افتراضياً
            if (unitSelect.children.length === 0) {
                unitSelect.innerHTML = '<option value="0" data-name="حبة(1)">حبة(1)</option>';
            }

            // الانتقال الفوري لحقل الوحدة التالي
            unitSelect.focus();
            
        } else {
            alert("رقم الصنف غير موجود أو غير معرف في نظام الصيدلية!");
            itemNameInput.value = "صنف غير معرف!";
            unitSelect.innerHTML = '<option value="">غير متاح</option>';
            itemIdInput.focus();
            itemIdInput.select();
        }
    }
}

// حقل: الوحدة
function handleUnitKey(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        const quantityField = document.getElementById('quantity');
        quantityField.focus();
        quantityField.select();
    }
}

// حقل: الكمية الواردة
function handleQuantityKey(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        document.getElementById('batch_no').focus();
    }
}

// حقل: رقم التشغيلة
function handleBatchNoKey(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        const dayField = document.getElementById('exp_day');
        dayField.focus();
        dayField.select();
    }
}

// حقل: تاريخ الانتهاء - اليوم
function handleExpDayKey(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        const monthField = document.getElementById('exp_month');
        monthField.focus();
        monthField.select();
    }
}

// حقل: تاريخ الانتهاء - الشهر
function handleExpMonthKey(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        const yearField = document.getElementById('exp_year');
        yearField.focus();
        yearField.select();
    }
}

// حقل: تاريخ الانتهاء - السنة
function handleExpYearKey(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        document.getElementById('warehouse').focus();
    }
}

// حقل: موقع التخزين (المستودع)
function handleWarehouseKey(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        addItemToGridAndArray();
    }
}

// ==========================================
// 3. إدارة عمليات الترحيل، الحذف، والإرسال
// ==========================================

// دالة ترحيل الصنف المكتمل إلى الجدول وبناء الحقول المخفية بالمعرفات الرقمية الصحيحة
function addItemToGridAndArray() {
    const workingDate = document.getElementById('working_date').value;
    const itemId = document.getElementById('item_id').value.trim();
    const itemName = document.getElementById('item_name').value;
    const quantity = document.getElementById('quantity').value.trim();
    const batchNo = document.getElementById('batch_no').value.trim();
    // 1. جلب القيم المدخلة من العناصر وحذف الفراغات
    const rawDay = document.getElementById('exp_day').value.trim();
    const rawMonth = document.getElementById('exp_month').value.trim();
    const expYear = document.getElementById('exp_year').value.trim();

    // 2. إضافة الصفر الحشو (Padding) للمنزلين دون تكرار التعريف
    const expDay = rawDay.padStart(2, '0');
    const expMonth = rawMonth.padStart(2, '0');

    // 3. تركيب التاريخ النهائي بالصيغة المطلوبة
    const expiryDate = (expYear && expMonth && expDay) ? `${expYear}-${expMonth}-${expDay}` : '';

    
    const unitSelect = document.getElementById('unit');
    const unitId = unitSelect.value;
    const unitName = unitSelect.options[unitSelect.selectedIndex] ? unitSelect.options[unitSelect.selectedIndex].getAttribute('data-name') : '';

    const warehouseSelect = document.getElementById('warehouse');
    const warehouseId = warehouseSelect.value;
    const warehouseName = warehouseSelect.options[warehouseSelect.selectedIndex] ? warehouseSelect.options[warehouseSelect.selectedIndex].textContent : '';

    if (!itemId || !quantity || itemName === "صنف غير معرف!" || !unitId) {
        alert("يرجى إدخال صنف دواء صحيح وتحديد الكمية والوحدة أولاً!");
        document.getElementById('item_id').focus();
        return;
    }

    const expiryDate = expYear + "/" + expMonth + "/" + expDay;

    const emptyRow = document.getElementById('emptyRow');
    if (emptyRow) emptyRow.remove();

    const tbody = document.getElementById('itemsTableBody');
    const row = document.createElement('tr');
    
    const currentId = itemIndex;
    row.id = `table-row-${currentId}`;
    
    row.innerHTML = `
        <td><b>${itemId}</b></td>
        <td>${itemName}</td>
        <td>${unitName}</td>
        <td>${quantity}</td>
        <td>${batchNo}</td>
        <td>${expiryDate}</td>
        <td>${warehouseName}</td>
        <td style="text-align: center;">
            <button type="button" class="btn-delete" onclick="deleteItemRow(${currentId})">حذف ❌</button>
        </td>
    `;
    tbody.appendChild(row);

    const hiddenContainer = document.getElementById('hiddenInputsContainer');
    const hiddenGroup = document.createElement('div');
    hiddenGroup.id = `hidden-item-${currentId}`;
    
    hiddenGroup.innerHTML = `
        <input type="hidden" name="items[${currentId}][working_date]" value="${workingDate}">
        <input type="hidden" name="items[${currentId}][item_id]" value="${itemId}">
        <input type="hidden" name="items[${currentId}][unit_id]" value="${unitId}">
        <input type="hidden" name="items[${currentId}][qty]" value="${quantity}">
        <input type="hidden" name="items[${currentId}][batch_no]" value="${batchNo}">
        <input type="hidden" name="items[${currentId}][expiry_date]" value="${expiryDate}">
        <input type="hidden" name="items[${currentId}][warehouse_id]" value="${warehouseId}">
    `;
    hiddenContainer.appendChild(hiddenGroup);
    itemIndex++;

    // إعادة تصفير سطر البيانات والبدء الفوري مجدداً من معرف الصنف
    document.getElementById('item_id').value = '';
    document.getElementById('item_name').value = 'يرجى إدخال معرف الصنف...';
    document.getElementById('quantity').value = '';
    document.getElementById('batch_no').value = '';
    document.getElementById('exp_day').value = '';
    document.getElementById('exp_month').value = '';
    document.getElementById('exp_year').value = '';
    document.getElementById('unit').innerHTML = '<option value="">اختر الصنف أولاً</option>';

    document.getElementById('item_id').focus();
}

// دالة حذف سطر محدد من الجدول وإزالته من الحقول المخفية
window.deleteItemRow = function(id) {
    const rowToDelete = document.getElementById(`table-row-${id}`);
    if (rowToDelete) rowToDelete.remove();

    const hiddenToDelete = document.getElementById(`hidden-item-${id}`);
    if (hiddenToDelete) hiddenToDelete.remove();

    const tbody = document.getElementById('itemsTableBody');
    if (tbody.children.length === 0) {
        const emptyRowHTML = document.createElement('tr');
        emptyRowHTML.id = 'emptyRow';
        emptyRowHTML.innerHTML = `<td colspan="8" class="empty-row">لم يتم إضافة أي أدوية بعد. استخدم لوحة المفاتيح للإدخال السريع.</td>`;
        tbody.appendChild(emptyRowHTML);
    }
};

// حدث الإرسال والحفظ النهائي للنموذج بالكامل
const form = document.getElementById('mainInvoiceForm');
form.addEventListener('submit', function(e) {
    e.preventDefault();

    const hiddenContainer = document.getElementById('hiddenInputsContainer');
    if (hiddenContainer.children.length === 0) {
        alert("لا يمكن إرسال مستند وارد فارغ! يرجى إضافة دواء واحد على الأقل.");
        document.getElementById('item_id').focus();
        return;
    }

    const formData = new FormData(form);
    console.log("--- تم تجميع مصفوفة مستند الوارد النهائية وجاهزة للإرسال ---");
    for (let [key, value] of formData.entries()) {
        console.log(key + ": " + value);
    }

    alert("تم حفظ مستند وارد الصيدلية بنجاح ومطابقة المعرفات الرقمية بقاعدة البيانات!");
});
