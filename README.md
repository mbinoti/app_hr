# app_hr

Aplicativo Flutter para consulta de dados HR no Firebase/Firestore.

## Firebase

O projeto ja inicializa o Firebase antes de abrir a UI e expoe um wrapper simples
para acesso ao Firestore em `lib/firebase/firestore_database.dart`.

Configuracao atual:

- iOS: `ios/Runner/GoogleService-Info.plist` ja esta presente para o projeto
  Firebase `hr-oracle`.
- Android: o Gradle ja esta preparado para aplicar `com.google.gms.google-services`
  quando o arquivo `android/app/google-services.json` existir.

Para completar o Android:

1. No console do Firebase, abra o projeto `hr-oracle`.
2. Cadastre um app Android com package name `com.u2m.app_hr`.
3. Baixe o `google-services.json`.
4. Coloque o arquivo em `android/app/google-services.json`.
5. Rode:

```sh
/Users/marcos/fvm/versions/3.44.1/bin/flutter pub get
/Users/marcos/fvm/versions/3.44.1/bin/flutter run
```

## Popular o Firestore com o HR

O arquivo SQL relacional `hr_populate.sql` pode ser importado para o modelo
NoSQL do Firestore usando o script `scripts/import_hr_firestore.js`. Ele le o
SQL, resolve os relacionamentos, duplica os campos necessarios para consulta e
cria as colecoes:

- `regions`, `countries`, `locations`, `departments`, `jobs`
- `employees`, com subcolecao `jobHistory`
- `jobHistory`, como colecao global
- `organizationSummary/global`

Instale a dependencia do importador:

```sh
npm install
```

Teste a conversao sem gravar no Firebase:

```sh
npm run import:hr:dry-run
```

Para gravar no projeto Firebase `hr-oracle`, autentique o Admin SDK com uma
credencial local e rode:

```sh
export GOOGLE_APPLICATION_CREDENTIALS="/caminho/para/service-account.json"
npm run import:hr
```

Para apagar os documentos principais antes de importar novamente:

```sh
npm run import:hr -- --clear
```
# newsflow
# app_hr
