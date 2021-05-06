<template>
  <div class="my-auto">
    <h2 class="mb-5">{{ $t('projects.title') }}</h2>

    <CardProject
      v-for="project in $t('projects.projectsInfo')"
      :key="project.name"
      :project-info="project"
      class="mb-5"
    />
  </div>
</template>

<script>
import CardProject from '@/components/Sections/CardProject';

export default {
  components: { CardProject },
  data() {
    return {};
  },
};
</script>
