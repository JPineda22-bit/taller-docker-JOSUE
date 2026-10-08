FROM python:3.11-slim AS builder

WORKDIR /build

COPY requirements.txt pyproject.toml ./

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-slim AS final

WORKDIR /app

RUN useradd -m -u 1000 appuser && \
    mkdir -p /app/datos && \
    chown -R appuser:appuser /app

COPY --from=builder /install /usr/local

COPY --chown=appuser:appuser prestamos/ /app/prestamos/

USER appuser

EXPOSE 9000

HEALTHCHECK --interval=5s --timeout=3s --retries=3 --start-period=5s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:9000/salud')" || exit 1

CMD ["uvicorn", "prestamos.servidor:app", "--host", "0.0.0.0", "--port", "9000"]