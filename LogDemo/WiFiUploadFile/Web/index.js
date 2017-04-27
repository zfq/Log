window.onload = function(e) {
    var tabs = document.querySelectorAll("a.send_type_link");
    var panels = document.querySelectorAll("#contentPlaceholder,#fileLists");

    tabs.forEach( function(tabEle, index) {
        tabEle.addEventListener('click', function() {
            //先让所有的隐藏
            panels.forEach( function(panelEle, index) {
                panelEle.style.display = 'none';
            });

            //再让当前的显示
            document.querySelector(tabEle.dataset.panelId).style.display = 'block';

            tapTabAction(index);
        });
    });

    //设置默认显示第0个
    tabs[0].click();
}

function upload() {
    //获取表单内容
    var formData = new FormData();
    var files = document.getElementById('tmpFileId').files;
    //怎么添加文件到form表单里
    formData.append('fileName',files[0]);

    var xhr = new XMLHttpRequest();
    xhr.open('POST','http://127.0.0.1:8091/upload',true);

    //上传完成的回调
    xhr.onload = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            console.log('上传成功');
        } else {
            console.log('上传失败%d',xhr.status);
        }
    };

    //将表单内容发送给服务器
    xhr.send(formData);
}

function uploadTest2(file) {
    var formData = new FormData();
    formData.append("my111",file);

    var xhr = new XMLHttpRequest();
    xhr.open("POST", "http://127.0.0.1:8091/upload", true);
    xhr.send(formData);
}

function showFileLists() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET','http://127.0.0.1:8091/files');
    xhr.onload = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            var obj = xhr.responseText;

            console.log('请求成功',obj);
        } else {
            console.log('请求失败%d',xhr.status);
        }
    };
    xhr.onreadystatechange = function () {
        console.log('请求状态为:' + xhr.status);
    }
    xhr.send();
}

function tapTabAction(index) {
    // body...
    if (index == 1) {
        showFileLists();
    }
}

//-----为拖拽框添加事件监听
var dropZone = document.getElementById('drop_zone');
/*
    释放目标时触发的事件
    drageover：当某被拖动的对象在另一对象容器范围内拖动时触发此事件,注意 在拖动元素时，每隔 350 毫秒会触发一次 ondragover 事件。
            默认情况下，数据/元素不能放置到其他元素中，如果要实现该功能，我们需要防止元素的默认处理方法，可以通过调用
            event.preventDefault()方法来实现ondrageover事件.
*/
dropZone.addEventListener('dragover',function (event) {
    event.preventDefault();
}, false);

/*
    释放目标时触发的事件
    拖拽完成，获取文件信息并上传
*/
dropZone.addEventListener('drop',function (event) {
    event.preventDefault();
    var files = event.dataTransfer.files;

    //获取文件名称
    var htmlStr = '<ul>';
    for (var i = 0; i <  files.length; i++) {
        htmlStr = htmlStr + "<li>" + files[i].name + "</li>";
    }
    htmlStr = htmlStr + '</ul>'
    //显示文件列表
    document.getElementById('file_list').innerHTML = htmlStr;

    event.dataTransfer.dropEffect = 'copy';
    uploadTest2(files[0]);

    
}, false);
