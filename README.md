# Learn-data-versioning-with-DVC

## Prerequisite
1. Run minio server
```bash
    docker compose up -d --build
```
2. Login minio server
```bash
    username: tutorial_dvc
    password: pass123456789
```
3. Create a bucket with name **tutorial-bucket**

## Setup DVC
```
dvc init

## Create remote storage
dvc remote add minio_storage s3://tutorial-bucket

## Modify url of minio_storage
dvc remote modify minio_storage endpointurl http://localhost:12000

## Modify credentials of minio_storage
## Create access key first
dvc remote modify --local minio_storage access_key_id 'MS73K6vU9nlX4QCT4lLo'
dvc remote modify --local minio_storage secret_access_key 'itUCQ69p9AhaTh2FGSKGpcophT71LmsZCc870FEE'

```

## Insert a Data to DVC
```
dvc add data/data.txt
git add data/data.txt.dvc data/.gitignore
git commit -m "data v1.0"
git push
```