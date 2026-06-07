FROM debian:bookworm-slim@sha256:f06537653ac770703bc45b4b113475bd402f451e85223f0f2837acbf89ab020a

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tzdata libasan8 wget \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates

# 1. Environment Variables: Tell the app to natively use HF's default port
ENV TZ=Asia/Shanghai
ENV PORT=7860

# 2. Security: Create the standard Hugging Face user (UID 1000)
RUN useradd -m -u 1000 user

# 3. Permissions: Create the /data folder and give our new user full ownership
RUN mkdir -p /data /licenses && chown -R user:user /data /licenses

# 4. Copy the compiled binary and assign ownership (--chown prevents root lockouts)
COPY --from=builder2 --chown=user:user /build/new-api /new-api
COPY --chown=user:user LICENSE NOTICE THIRD-PARTY-LICENSES.md /licenses/

# 5. Switch out of root before the container starts
USER user

EXPOSE 7860
WORKDIR /data
ENTRYPOINT ["/new-api"]
