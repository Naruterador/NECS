## 题目
- 在linux4上编写/root/createfile.py的python3脚本，创建20个文件/root/python/file00至/root/python/file19，如果文件存在，则删除再创建；每个文件的内容同文件名，如file00文件的内容为“file00”。

```python
import os

directory = '/root/python'
os.makedirs(directory, exist_ok=True)

for i in range(20):
    filename = f"file{i:02d}"
    filepath = os.path.join(directory, filename)
    if os.path.exists(filepath):
        os.remove(filepath)
    with open(filepath, 'w') as f:
        f.write(filename)
```