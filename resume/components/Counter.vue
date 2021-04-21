<template>
  <div class="counter">
    <template v-if="$fetchState.pending">
      <span>Welcome</span>
    </template>
    <template v-else>
      <span>{{ users }}</span>
    </template>
  </div>
</template>

<script>
export default {
  data() {
    return {
      users: '',
    };
  },
  async fetch() {
    this.users = await fetch(process.env.functionUrl).then((res) => res.text());
  },
  fetchOnServer: false,
};
</script>
