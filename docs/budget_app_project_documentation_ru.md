---
marp: true
theme: default
paginate: true
style: |
  section {
    font-size: 18px;
    line-height: 1.4;
    padding: 28px 40px;
  }
  h1 {
    font-size: 28px;
    margin-bottom: 10px;
  }
  h2 {
    font-size: 22px;
    margin-bottom: 6px;
  }
  ul {
    margin: 8px 0;
  }
  li {
    margin: 3px 0;
  }
---

# Budget App
Local-first приложение для учёта финансов  
Flutter · Hive · Supabase

---

## Проблема, решение и стек

- Разрозненный учёт (заметки, Excel)
- Нет мгновенного понимания баланса
- Зависимость от интернета
- Потеря данных при смене устройства

- Счета, категории, транзакции — в одном месте
- **Local-first (Hive)** -> быстрый UI
- **Supabase** -> авторизация + backup
- Контроль бизнес-правил (баланс >= 0)
- Аналитика и графики

| Область | Технологии |
|--------|-----------|
| UI | Flutter |
| State | Bloc / Cubit |
| Local | Hive CE |
| Backend | Supabase |
| Models | Freezed / JSON |
| Charts | fl_chart |

---

## Архитектура и развитие

```
features/budget/
├── domain/
├── data/
└── presentation/
```

- domain — бизнес-логика
- data — источники данных
- presentation — UI + Cubit

UI -> Cubit -> Repository -> Local (Hive)  
-> Remote (Supabase)

- Чтение -> local-first
- Запись -> сначала локально
- Sync -> best-effort

Ключевые улучшения:
- аналитика: pie/line chart + monthly summary
- умные финансы: лимиты, предупреждения, прогноз баланса
- multi-account: cash/card/savings + переводы
- offline advanced: conflict resolution + manual sync + versioning
- безопасность и данные: CSV экспорт/импорт, PIN/FaceID, шифрование Hive

Roadmap:
- **Phase 1**: sync queue + retry, базовая аналитика
- **Phase 2**: бюджеты по категориям, multi-account
- **Phase 3**: AI рекомендации, advanced sync
