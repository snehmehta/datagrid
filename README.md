# DataGrid

## Run without hassle
If you just want to see, play with the output, check [Zapp.run](https://zapp.run/edit/flutter-zk1w064ik1x0?entry=lib/main.dart&file=lib/main.dart)
## Task

To create YAML configurable responsive data grid widget.

## Sample YAML

```yaml
sourceType: remote
sourcePath: https://us-central1-fir-apps-services.cloudfunctions.net/transactions
titleColumnIndex: 3
subTitleColumnIndex: 4
config:
  - label: Name
    key: name
    type: string
  - label: Data
    key: date
    type: date
  - label: Category
    key: category
    type: string
  - label: Amount
    key: amount
    type: number
  - label: Created
    key: created_at
    type: date

```

## Output

![Output](https://i.imgur.com/e6ve6E4.gif)

