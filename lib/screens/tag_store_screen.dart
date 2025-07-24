import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iap_provider.dart';

// TagStoreScreen displays a list of tag packs available for purchase.
class TagStoreScreen extends StatefulWidget {
  static const routeName = '/tag-store'; // Route name for navigation

  const TagStoreScreen({Key? key}) : super(key: key);

  @override
  State<TagStoreScreen> createState() => _TagStoreScreenState();
}

class _TagStoreScreenState extends State<TagStoreScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch available tag packs when the screen initializes
    Provider.of<IapProvider>(context, listen: false).fetchTagPacks();
  }

  @override
  Widget build(BuildContext context) {
    final iapProvider = Provider.of<IapProvider>(context); // Access IapProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag Store'), // AppBar title
      ),
      body: iapProvider.availableTagPacks.isEmpty
          ? const Center(
              child: CircularProgressIndicator(), // Show loading indicator if no tag packs are available
            )
          : ListView.builder(
              itemCount: iapProvider.availableTagPacks.length, // Number of tag packs
              itemBuilder: (ctx, i) {
                final tagPack = iapProvider.availableTagPacks[i]; // Current tag pack
                return Card(
                  margin: const EdgeInsets.all(10), // Card margin
                  child: Padding(
                    padding: const EdgeInsets.all(15), // Padding inside card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align content to start
                      children: [
                        Text(
                          tagPack.name, // Tag pack name
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5), // Spacer
                        Text(tagPack.description ?? 'No description'), // Tag pack description
                        const SizedBox(height: 10), // Spacer
                        Align(
                          alignment: Alignment.bottomRight, // Align button to bottom right
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                // Attempt to purchase the tag pack
                                final success = await iapProvider
                                    .purchaseTagPack(tagPack.productId);
                                if (!mounted) return;
                                if (success) {
                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${tagPack.name} purchased successfully!')),
                                  );
                                } else {
                                  // Show generic purchase failed message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Purchase failed.')),
                                  );
                                }
                              } catch (error) {
                                // Handle purchase errors and display detailed message
                                String errorMessage =
                                    'An unknown error occurred.';
                                if (error is Exception) {
                                  errorMessage = error
                                      .toString()
                                      .replaceFirst('Exception: ', '');
                                }
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error: ${errorMessage}')),
                                );
                              }
                            },
                            child: Text(
                                'Buy for ${tagPack.price / 100}'), // Display price
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
