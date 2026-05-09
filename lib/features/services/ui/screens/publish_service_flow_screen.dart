import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/widgets/loading_overlay.dart';

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
      listenWhen: (prev, curr) => prev.currentStep != curr.currentStep,
      listener: (context, state) {
        _handleStepChange(state.currentStep);
      },
      builder: (context, state) {
        final isLastStep = state.currentStep == 4;
        final progress = (state.currentStep + 1) / 5;

        return LoadingOverlay(
          isLoading: state.status == ServicePublishStatus.loading,
          message: 'Publicando servicio...',
          child: Scaffold(
            backgroundColor: AppTheme.background,
            appBar: isLastStep
                ? null
                : AppBar(
                    title: const Text('Publicar Limpieza'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppTheme.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
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
                if (!isLastStep) _buildNavigationButtons(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons(BuildContext context, ServicePublishState state) {
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
                    onPressed: () {
                      context.read<ServicePublishBloc>().add(const ServicePublishPrevStepEvent());
                    },
                    child: const Text('Atrás'),
                  ),
                ),
              ),
            Expanded(
              flex: 2,
              child: CustomButton(
                label: isSubmitStep ? 'Publicar Ahora' : 'Continuar',
                onPressed: () {
                  if (isSubmitStep) {
                    context.read<ServicePublishBloc>().add(const ServicePublishSubmitEvent());
                  } else {
                    context.read<ServicePublishBloc>().add(const ServicePublishNextStepEvent());
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
