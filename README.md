# Scooper

Socle MVP Flutter pour la gestion d'établissements scolaires avec Supabase.

## Démarrage

```bash
flutter pub get
flutter run
```

L'application utilise Supabase Auth pour l'email/mot de passe, la vérification email, la récupération de compte et Google OAuth.

Pour Google OAuth, activez le fournisseur Google dans Supabase Authentication et ajoutez `io.supabase.scooper://login-callback` aux URLs de redirection autorisées. Renseignez ensuite les identifiants OAuth Google du projet dans Supabase ; ils ne doivent jamais être placés dans Flutter.

## Base de données

Le schéma initial et les politiques RLS sont versionnés dans `supabase/migrations/202610030001_initial_schema.sql`. Cette migration crée les profils, établissements, membres, emplois du temps et notifications.

Les rôles et l'appartenance à un établissement sont contrôlés par PostgreSQL/RLS. Le client Flutter ne peut pas s'attribuer un rôle ni accéder aux données d'un autre établissement.
