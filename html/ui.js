// Progressbar logic
let pb_interval = null;
let pb_total = 0;
let pb_left = 0;

// Sellitem logic
let sellitem_max = 1;

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === 'show') {
        if (data.text && data.time) {
            // Show progressbar
            document.getElementById('progressbar-container').style.display = 'flex';
            document.getElementById('progressbar-desc').innerText = data.text || '';
            pb_total = data.time || 1000;
            pb_left = pb_total;
            // Mostrar imagem se enviada
            if (data.itemImage) {
                let pbImg = document.getElementById('progressbar-img');
                pbImg.style.display = 'block';
                pbImg.src = data.itemImage;
            } else {
                document.getElementById('progressbar-img').style.display = 'none';
                document.getElementById('progressbar-img').src = '';
            }
            updateBar();
            if (pb_interval) clearInterval(pb_interval);
            pb_interval = setInterval(() => {
                pb_left -= 100;
                updateBar();
                if (pb_left <= 0) {
                    clearInterval(pb_interval);
                    document.getElementById('progressbar-container').style.display = 'none';
                    document.getElementById('progressbar-img').style.display = 'none';
                    document.getElementById('progressbar-img').src = '';
                    fetch(`https://${GetParentResourceName()}/finish`, {method: 'POST'});
                }
            }, 100);
        } else if (data.item) {
            // Show sellitem modal
            document.getElementById('sellitem-modal').style.display = 'flex';
            let imgPath = data.itemImage || '';
            if (imgPath.startsWith('nui://')) {
                document.getElementById('sellitem-img').src = imgPath;
            } else if (imgPath.startsWith('http')) {
                document.getElementById('sellitem-img').src = imgPath;
            } else if (imgPath.length > 0) {
                document.getElementById('sellitem-img').src = 'nui://' + imgPath;
            } else {
                document.getElementById('sellitem-img').src = '';
            }
            document.getElementById('sellitem-name').innerText = data.itemLabel || '';
            sellitem_max = data.max || 1;
            document.getElementById('sellitem-amount').value = 1;
            document.getElementById('sellitem-amount').max = sellitem_max;
        }
    } else if (data.action === 'hide') {
        document.getElementById('progressbar-container').style.display = 'none';
        document.getElementById('sellitem-modal').style.display = 'none';
        if (pb_interval) clearInterval(pb_interval);
    }
});

function updateBar() {
    let percent = Math.max(0, Math.min(1, pb_left / pb_total));
    document.getElementById('progressbar-bar').style.width = (percent * 100) + '%';
    document.getElementById('progressbar-time').innerText = (pb_left/1000).toFixed(1) + 's';
}

document.getElementById('sellitem-all').onclick = function() {
    document.getElementById('sellitem-amount').value = sellitem_max;
};
document.getElementById('sellitem-confirm').onclick = function() {
    let amount = parseInt(document.getElementById('sellitem-amount').value);
    if (isNaN(amount) || amount < 1) amount = 1;
    if (amount > sellitem_max) amount = sellitem_max;
    fetch(`https://${GetParentResourceName()}/sellitem_confirm`, {
        method: 'POST',
        body: JSON.stringify({
            amount: amount,
            itemImage: document.getElementById('sellitem-img').src
        })
    });
    document.getElementById('sellitem-modal').style.display = 'none';
};
document.getElementById('sellitem-cancel').onclick = function() {
    fetch(`https://${GetParentResourceName()}/sellitem_cancel`, {method: 'POST'});
    document.getElementById('sellitem-modal').style.display = 'none';
}; 