<template>
  <span>{{ users }}</span>
</template>

<script>
export default {
  data() {
    return {
      users: 0,
    };
  },
  async fetch() {
    this.users = await fetch(process.env.functionUrl).then((res) => res.text());
  },
};
</script>
