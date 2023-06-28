class ToDo {
  int? id;
  String? text;
  bool isDone;

  ToDo({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  static List<ToDo> todoList() {
    return [
      ToDo(
        id: 1,
        text: 'Утренняя разминка',
        isDone: true,
      ),
      ToDo(
        id: 2,
        text: 'Купить продукты',
        isDone: true,
      ),
      ToDo(
        id: 3,
        text: 'Проверить почту',
        isDone: true,
      ),
      ToDo(
        id: 4,
        text: 'Командное собрание',
      ),
      ToDo(
        id: 5,
        text: 'Разминка',
      ),
      ToDo(
        id: 6,
        text: 'Прогуляться в парке',
      ),
      ToDo(
        id: 7,
        text: 'Приготовить ужин',
      ),
      ToDo(
        id: 8,
        text: 'Покормить собаку',
      ),
      ToDo(
        id: 9,
        text: 'Отсортировать фотографии с отдыха',
      ),
      ToDo(
        id: 10,
        text: 'Утренняя разминка',
        isDone: true,
      ),
      ToDo(
        id: 11,
        text: 'Купить продукты',
        isDone: true,
      ),
      ToDo(
        id: 12,
        text: 'Проверить почту',
        isDone: true,
      ),
      ToDo(
        id: 13,
        text: 'Командное собрание',
      ),
      ToDo(
        id: 14,
        text: 'Разминка',
      ),
      ToDo(
        id: 15,
        text: 'Прогуляться в парке',
      ),
      ToDo(
        id: 16,
        text: 'Приготовить ужин',
      ),
      ToDo(
        id: 17,
        text: 'Покормить собаку',
      ),
      ToDo(
        id: 18,
        text: 'Отсортировать фотографии с отдыха',
      ),
    ];
  }
}
