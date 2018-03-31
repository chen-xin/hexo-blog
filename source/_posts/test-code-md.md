---
title: test-code.md
date: 2018-02-14 09:35:24
tags:
- code
---

Javascript

``` js
const a = 11
console.log(a)

router.get('/', (req, res, next) =>{
  let accessibles = {};
  for (url of req.session.user.accessibles)
    accessibles[url] = true;
  res.render('frame.docman.html',{
    'realname':req.session.user.realname,
    'activemenu':'docman',
    'accessibles': accessibles
})});
```

Python

``` python
from PathLib import path

a = 100

for i in range(a):
    print(i)

class FileChooser(Frame):
    def __init__(self, parent=None):
        Frame.__init__(self, parent)
        self.parent = parent
        self.initialize()

    def ask_dir(self):
        dirname = askdirectory()
        if dirname:
            self.source_path.set(dirname)

    def run_check(self):
        self.process_info.set('正在处理，请稍候..')
        self.parent.config(cursor="wait")
        self.parent.update()
        # check_path(self.source_path.get())
        try:
            result = check_path(self.source_path.get()) + '\n完成！请检查单位目录下的[核查结果.xlsx]文件。'
        except Exception as e:
            result = str(e)
        self.process_info.set(result)
        self.parent.config(cursor="")
```


