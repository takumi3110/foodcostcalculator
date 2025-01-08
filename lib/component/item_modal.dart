import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class ItemModal extends StatefulWidget {
  // final TextEditingController nameController;
  // final TextEditingController priceController;
  // final TextEditingController unitPriceController;
  // final TextEditingController costCountController;
  final Function onPressAdd;

  // final double sliderValue;
  // final Function onChangeSliderValue;

  const ItemModal({
    super.key,
    // required this.nameController,
    // required this.priceController,
    // required this.unitPriceController,
    // required this.costCountController,
    required this.onPressAdd,
    // required this.sliderValue,
    // required this.onChangeSliderValue
  });

  @override
  State<ItemModal> createState() => _ItemModalState();
}

class _ItemModalState extends State<ItemModal> {
  TextEditingController nameController = TextEditingController();
  TextEditingController unitPriceController = TextEditingController();
  TextEditingController costCountController = TextEditingController();
  TextEditingController priceController = TextEditingController(text: '0');
  double _currentSliderValue = 0;

  // onPressCancel() {
  //               Navigator.pop(context);
  //               nameController.clear();
  //               unitPriceController.clear();
  //               costCountController.clear();
  //               priceController.clear();
  //             }


  @override
  Widget build(BuildContext context) {
    // keyboard
    final FocusNode nodeText1 = FocusNode();
    final FocusNode nodeText2 = FocusNode();

    KeyboardActionsConfig buildConfig(BuildContext context) {
      return KeyboardActionsConfig(
          keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
          keyboardBarColor: Colors.grey[200],
          nextFocus: true,
          actions: [
            KeyboardActionsItem(focusNode: nodeText1, toolbarButtons: [
              (node) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextButton(
                      onPressed: () => node.unfocus(),
                      child: const Text('完了',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold))),
                );
              }
            ]),
            KeyboardActionsItem(focusNode: nodeText2, toolbarButtons: [
              (node) {
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                        onPressed: () => node.unfocus(),
                        child: const Text(
                          '完了',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        )));
              }
            ]),
          ]);
    }

    return Container(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height * 0.8,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: KeyboardActions(
                              config: buildConfig(context),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextField(
                                    controller: nameController,
                                    focusNode: nodeText1,
                                    decoration: const InputDecoration(
                                        labelText: '商品名',
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.text,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '買ったものから登録',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        Icon(
                                          Icons.launch,
                                          color: Colors.blue,
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 170,
                                    child: TextField(
                                      controller: unitPriceController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.right,
                                      focusNode: nodeText2,
                                      decoration: const InputDecoration(
                                          labelText: '金額',
                                          border: OutlineInputBorder(),
                                          suffix: Text('円')),
                                      onChanged: (String value) {
                                        if (value != '' &&
                                            costCountController
                                                .text.isNotEmpty) {
                                          var sumPrice = (int.parse(value) *
                                                  double.parse(
                                                      costCountController.text))
                                              .round();
                                          priceController.text =
                                              sumPrice.toString();
                                        }
                                      },
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Text('使った量'),
                                      Slider(
                                          value: _currentSliderValue,
                                          max: 100,
                                          divisions: 10,
                                          label: '${_currentSliderValue.round()}%',
                                          onChanged: (double value) => {
                                                setState(() {
                                                  _currentSliderValue = value;
                                                  costCountController.text =
                                                      value.round().toString();
                                                })
                                              }),
                                      Text('${_currentSliderValue.round()}%')
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: ElevatedButton(
                                        onPressed: () => {
                                              if (nameController
                                                      .text.isNotEmpty &&
                                                  priceController
                                                      .text.isNotEmpty &&
                                                  unitPriceController
                                                      .text.isNotEmpty &&
                                                  costCountController
                                                      .text.isNotEmpty)
                                                {
                                                  widget.onPressAdd(
                                                      nameController.text,
                                                      int.parse(
                                                          priceController.text),
                                                      int.parse(
                                                          unitPriceController
                                                              .text),
                                                      int.parse(
                                                          costCountController
                                                              .text))
                                                }
                                            },
                                        child: const Text('登録')),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );

  }
}
