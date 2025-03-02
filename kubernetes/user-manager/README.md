User Manager
==============

## Dependencies

### List

* `pip3 install flask`
* `pip3 install redis`
* `pip3 install ddtrace`

### venv

[Documentation](https://docs.python.org/3/tutorial/venv.html)

Install the dependencies.

1. Create the environment `python3 -m venv venv`
2. Activate it `source venv/bin/activate` (for Mac)
3. Install the packages `python -m pip install -r requirements.txt`
4. (optional) Check the packages `pip list`

If the dependencies are already installed, just activate the right env with `source venv/bin/activate`.

```
pip freeze > requirements.txt
```
