# Hatsune Task

Aplicativo de gerenciamento de tarefas pessoais.
![Uploading Hatsune Task.gif…]()

---

## Funcionalidades

- Autenticação com Firebase Auth (e-mail e senha)
- Cadastro de novo usuário com validação de campos
- Listagem de tarefas em **tempo real** via Firestore
- Criar, editar e excluir tarefas
- Marcar tarefa como concluída (checkbox ou swipe)
- Filtro por status: Todas, Pendentes, Concluídas
- Prioridade por tarefa: Alta, Média, Baixa
- Data limite com DatePicker
- Empty states, loading states e feedback visual (SnackBar)
- Redirecionamento automático baseado no estado de autenticação

---

## Tecnologias

- Flutter 3.x / Dart 3.x
- Firebase Authentication
- Cloud Firestore
- Provider (gerenciamento de estado)

---

## Gerenciamento de Estado: Provider

Escolhi **Provider com ChangeNotifier** por ser a solução mais adotada no mercado Flutter e por oferecer uma separação clara entre lógica de negócio e UI.

- `AuthController` gerencia o estado de autenticação (login, cadastro, logout)
- `TaskController` gerencia a lista de tarefas, filtros e operações CRUD
- As páginas usam `context.watch()` para reconstruir quando o estado muda
- Ações usam `context.read()` para não gerar rebuilds desnecessários

---

## Arquitetura: Feature-first

```
lib/
├── core/
│   ├── theme/app_theme.dart
│   ├── utils/validators.dart
│   └── widgets/
│       ├── custom_text_field.dart
│       ├── loading_button.dart
│       └── empty_state.dart
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart
│   │   ├── state/auth_controller.dart
│   │   └── presentation/
│   │       └── pages/
│   │           ├── login_page.dart
│   │           └── register_page.dart
│   └── tasks/
│       ├── data/
│       │   ├── models/task_model.dart
│       │   └── task_repository.dart
│       ├── state/task_controller.dart
│       └── presentation/
│           ├── pages/
│           │   ├── home_page.dart
│           │   └── task_form_page.dart
│           └── widgets/
│               ├── task_card.dart
│               └── priority_badge.dart
├── app.dart
└── main.dart
```

Cada feature contém suas próprias camadas de `data`, `state` e `presentation`, facilitando manutenção e escalabilidade.

---

## Modelo de dados (Firestore)

```
// Coleção: users/{uid}/tasks/{taskId}
{
  "title": "Estudar Flutter",
  "description": "Revisar provider",
  "priority": "high",        // high | medium | low
  "isCompleted": false,
  "dueDate": Timestamp,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

---

## Como rodar o projeto

### Pré-requisitos

- Flutter SDK 3.x instalado
- Conta no Firebase com projeto criado
- Firebase CLI instalado (`npm install -g firebase-tools`)
- FlutterFire CLI instalado (`dart pub global activate flutterfire_cli`)

### Configuração do Firebase

1. Acesse o [Firebase Console](https://console.firebase.google.com) e crie um projeto
2. Ative **Authentication → E-mail/Senha**
3. Crie o **Firestore Database** (modo de teste para desenvolvimento)
4. No terminal, dentro da pasta do projeto:

```bash
firebase login
flutterfire configure
```

Isso vai gerar o arquivo `lib/firebase_options.dart` com as credenciais do seu projeto.

> Os arquivos `google-services.json` e `firebase_options.dart` estão no `.gitignore` por conterem credenciais sensíveis. Cada desenvolvedor deve configurar seu próprio Firebase.

### Instalação e execução

```bash
# Instalar dependências
flutter pub get

# Rodar o app
flutter run
```

---

## Firebase Security Rules (produção)

As rules abaixo garantem que cada usuário acesse somente seus próprios dados:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/tasks/{taskId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

> Em desenvolvimento foi utilizado o modo de teste. As rules acima devem ser aplicadas antes de ir para produção.

---

## Decisões técnicas

| Decisão | Justificativa |
|---------|---------------|
| Provider | Adotado amplamente pelo mercado, separação clara estado/UI |
| Feature-first | Facilita manutenção e escalabilidade por domínio |
| Subcoleção Firestore | `users/{uid}/tasks` garante isolamento de dados por usuário |
| Stream em tempo real | Atualizações sem polling via `snapshots()` do Firestore |
| TaskModel tipado | Evita `dynamic`, facilita serialização com `fromJson`/`toJson` |
