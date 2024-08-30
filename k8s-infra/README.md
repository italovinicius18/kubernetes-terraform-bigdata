# k8s-infra

Repositório de recursos terraform responsáveis pela criação dos recursos de infraestrura AWS EKS.

## Instruções

### Executar localmente dev

1. Criar arquivo .env e definir variáveis:

```env
TF_BUCKET_PROD=
TF_BUCKET_DEV=
TF_KEY_PROD=
TF_KEY_DEV=
TF_REGION=
```

2. Exporte as variáveis para o ambiente

```bash
export $(cat .env | tr -d '\r' | xargs)
```

3. Iniciar terraform

```bash
terraform init -backend-config="bucket=${TF_BUCKET_DEV}" -backend-config="key=${TF_KEY_DEV}" -backend-config="region=${TF_REGION}"
```

4. Definir o workspace de trabalho

```bash
terraform workspace select -or-create dev
```