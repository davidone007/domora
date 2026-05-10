import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_button.dart';

import '../bloc/service_publish_bloc.dart';
import 'steps/step1_place_details.dart';
import 'steps/step2_general_info.dart';
import 'steps/step3_schedule.dart';
import 'steps/step4_location.dart';
import 'steps/step5_success.dart';

class PublishServiceFlowScreen extends StatefulWidget {
  const PublishServiceFlowScreen({super.key});

  @override
  State<PublishServiceFlowScreen> createState() => _PublishServiceFlowScreenState();
}

class _PublishServiceFlowScreenState extends State<PublishServiceFlowScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleStepChange(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServicePublishBloc, ServicePublishState>(
      listener: (context, state) {
        // Sincronizar el PageView con el estado del BLoC
        if (_pageController.hasClients &&
            _pageController.page?.toInt() != state.currentStep) {
          _handleStepChange(state.currentStep);
        }

        if (state.status == ServicePublishStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLastStep = state.currentStep == 4;
        final progress = (state.currentStep + 1) / 5;
        final isLoading = state.status == ServicePublishStatus.loading;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: isLastStep
              ? null
              : AppBar(
                  title: const Text('Publicar Limpieza'),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: isLoading ? null : () => context.pop(),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.border,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      minHeight: 4,
                    ),
                  ),
                ),
          body: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    Step1PlaceDetails(),
                    Step2GeneralInfo(),
                    Step3Schedule(),
                    Step4Location(),
                    Step5Success(),
                  ],
                ),
              ),
              if (!isLastStep) _buildNavigationButtons(context, state, isLoading),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons(
      BuildContext context, ServicePublishState state, bool isLoading) {
    final isFirstStep = state.currentStep == 0;
    final isSubmitStep = state.currentStep == 3;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!isFirstStep)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context
                                .read<ServicePublishBloc>()
                                .add(const ServicePublishPrevStepEvent());
                          },
                    child: const Text('Atrás'),
                  ),
                ),
              ),
            Expanded(
              flex: 2,
              child: CustomButton(
                label: isSubmitStep ? 'Publicar Ahora' : 'Continuar',
                isLoading: isLoading,
                onPressed: () {
                  if (isSubmitStep) {
                    context
                        .read<ServicePublishBloc>()
                        .add(const ServicePublishSubmitEvent());
                  } else {
                    context
                        .read<ServicePublishBloc>()
                        .add(const ServicePublishNextStepEvent());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
