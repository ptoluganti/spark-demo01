# FROM apache/spark-py:latest
FROM python:3.11.6

RUN apt-get install curl wget

# VERSIONS
ENV SPARK_VERSION=3.5.0 \
HADOOP_VERSION=3 \
JAVA_VERSION=21

# SET JAVA ENV VARIABLES
ENV JAVA_HOME="/home/jdk-${JAVA_VERSION}.0.2"
ENV PATH="${JAVA_HOME}/bin/:${PATH}"

# DOWNLOAD JAVA 11 AND INSTALL
RUN DOWNLOAD_URL="https://download.oracle.com/java/${JAVA_VERSION}/latest/jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz" \
    && TMP_DIR="$(mktemp -d)" \
    && curl -fL "${DOWNLOAD_URL}" --output "${TMP_DIR}/jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz" \
    && mkdir -p "${JAVA_HOME}" \
    && tar xzf "${TMP_DIR}/jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz" -C "${JAVA_HOME}" --strip-components=1 \
    && rm -rf "${TMP_DIR}" \
    && java --version

# DOWNLOAD SPARK AND INSTALL
RUN DOWNLOAD_URL_SPARK="https://www.apache.org/dyn/closer.lua/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
    && wget --no-verbose -O apache-spark.tgz  "${DOWNLOAD_URL_SPARK}"\
    && mkdir -p /home/spark \
    && tar -zxvf apache-spark.tgz -C /home/spark --strip-components=1 \
    && rm apache-spark.tgz

# SET SPARK ENV VARIABLES
ENV SPARK_HOME="/home/spark"
ENV PATH="${SPARK_HOME}/bin/:${PATH}"

# SET PYSPARK VARIABLES
ENV PYTHONPATH="${SPARK_HOME}/python/:$PYTHONPATH"
ENV PYTHONPATH="${SPARK_HOME}/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH"

# Let's change to  "$NB_USER" command so the image runs as a non root user by default
USER $NB_UID

WORKDIR /app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY main.py ./

CMD [ "python", "./main.py" ]
