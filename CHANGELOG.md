## 0.0.1
* Provide most of chat list functionalities
## 1.0.0
* Renamed properties

## 1.0.2
* Fixed keep alive issue

## 1.0.3
* Fixed touch item is incorrect when items can't fill full screen and firstItemAlign is FirstItemAlign.end

## 1.0.5
* Rewrite keep position logic

## 1.0.6
* Fixed random scrollposition error when refreshController.requestLoading was invoked. It caused by manually call refreshController.requestLoading(). The error will supress if we pass needMove: false.