FROM inspirehep/python-base

ADD . /code
WORKDIR /code

USER root
RUN virtualenv /code/virtualenv && \
    . /code/virtualenv/bin/activate && \
    pip install --upgrade pip && \
    pip install --upgrade setuptools && \
    pip install --find-links /pip-cache -r requirements.txt --pre -e .[tests,crawler] gunicorn --exists-action i && \
    scripts/clean_assets

