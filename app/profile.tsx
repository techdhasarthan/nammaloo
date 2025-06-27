import { View, Text, StyleSheet, TouchableOpacity, ScrollView, SafeAreaView, StatusBar } from 'react-native';
import { ArrowLeft, BookmarkCheck, Info } from 'lucide-react-native';
import { useState, useEffect } from 'react';
import { useRouter } from 'expo-router';

export default function ProfileScreen() {
  const router = useRouter();
  const [savedToiletsCount, setSavedToiletsCount] = useState(0);

  const handleBackPress = () => {
    router.back();
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#F8FAFC" />
      
      <SafeAreaView style={styles.safeArea}>
        {/* Back Button with PROPER spacing under status bar */}
        <View style={styles.headerContainer}>
          <TouchableOpacity 
            style={styles.headerButton}
            onPress={() => router.back()}
          >
            <ArrowLeft size={24} color="#1a1a1a" />
          </TouchableOpacity>
        </View>
          
        {/* Profile Title */}
        <View style={styles.profileHeader}>
          <Text style={styles.profileTitle}>Profile</Text>
        </View>

        <ScrollView 
          style={styles.scrollContainer}
          showsVerticalScrollIndicator={false}
          contentContainerStyle={styles.scrollContent}
        >
        {/* Profile Header */}
       

        {/* Saved Toilets Section */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <View style={styles.sectionTitleContainer}>
              <BookmarkCheck size={24} color="#10B981" />
              <Text style={styles.sectionTitle}>Saved Toilets</Text>
            </View>
          </View>
          
          <View style={styles.savedToiletsContent}>
            <View style={styles.savedToiletsStats}>
              <Text style={styles.savedCount}>{savedToiletsCount}</Text>
              <Text style={styles.savedLabel}>Toilets Saved</Text>
            </View>
            
            <View style={styles.savedToiletsPlaceholder}>
              <BookmarkCheck size={48} color="#D1D5DB" />
              <Text style={styles.placeholderText}>
                No saved toilets yet
              </Text>
              <Text style={styles.placeholderSubtext}>
                Start exploring and save your favorite toilets for quick access
              </Text>
            </View>
          </View>
        </View>

        {/* About Us Section */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <View style={styles.sectionTitleContainer}>
              <Info size={24} color="#EF4444" />
              <Text style={styles.sectionTitle}>About Us</Text>
            </View>
          </View>
          
          <View style={styles.aboutContent}>
            <Text style={styles.aboutTitle}>Namma Loo</Text>
            <Text style={styles.aboutVersion}>Version 1.0.0</Text>
            
            <Text style={styles.aboutDescription}>
              Namma Loo is your smart toilet finder app, designed to help you locate clean, 
              accessible, and well-maintained public toilets in your area. Our mission is to 
              make urban navigation more comfortable and convenient for everyone.
            </Text>
            
            <View style={styles.aboutTeam}>
              <Text style={styles.aboutSubtitle}>Developed by</Text>
              <Text style={styles.aboutTeamName}>Sprint6 Team</Text>
            </View>
            
            <View style={styles.aboutFeatures}>
              <Text style={styles.aboutSubtitle}>Features:</Text>
              <Text style={styles.aboutFeatureItem}>
                • Real-time toilet locator with GPS
              </Text>
              <Text style={styles.aboutFeatureItem}>
                • User reviews and ratings
              </Text>
              <Text style={styles.aboutFeatureItem}>
                • Accessibility information
              </Text>
              <Text style={styles.aboutFeatureItem}>
                • Save your favorite locations
              </Text>
              <Text style={styles.aboutFeatureItem}>
                • Working hours and availability
              </Text>
            </View>
            
            <Text style={styles.aboutFooter}>
              Making public facilities accessible to all. Thank you for using Namma Loo!
            </Text>
          </View>
        </View>
              </ScrollView>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8FAFC',
  },
  safeArea: {
    flex: 1,
    backgroundColor: '#F8FAFC',
  },
  
  // Header Container - PROPERLY positioned under status bar
  headerContainer: {
    paddingHorizontal: 24,
    paddingTop: 20,
    paddingBottom: 24,
    backgroundColor: '#F8FAFC',
  },
  headerButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 6,
    elevation: 4,
  },
  
  // Profile Header
  profileHeader: {
    alignItems: 'center',
    paddingVertical: 24,
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    marginHorizontal: 24,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 8,
    elevation: 2,
  },
  profileTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1F2937',
  },
  
  // Scroll Container
  scrollContainer: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 24,
    paddingBottom: 40,
  },
  
  // Section Styles
  section: {
    marginVertical: 12,
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    padding: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 8,
    elevation: 2,
  },
  sectionHeader: {
    marginBottom: 16,
  },
  sectionTitleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1F2937',
  },
  
  // Saved Toilets Styles
  savedToiletsContent: {
    alignItems: 'center',
  },
  savedToiletsStats: {
    alignItems: 'center',
    marginBottom: 24,
  },
  savedCount: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#1F2937',
    marginBottom: 4,
  },
  savedLabel: {
    fontSize: 14,
    fontWeight: '500',
    color: '#6B7280',
  },
  savedToiletsPlaceholder: {
    alignItems: 'center',
    paddingVertical: 20,
  },
  placeholderText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#6B7280',
    marginTop: 16,
    marginBottom: 8,
  },
  placeholderSubtext: {
    fontSize: 14,
    color: '#6B7280',
    textAlign: 'center',
    lineHeight: 20,
  },
  
  // About Us Styles
  aboutContent: {
    gap: 16,
  },
  aboutTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1F2937',
    textAlign: 'center',
  },
  aboutVersion: {
    fontSize: 14,
    color: '#6B7280',
    textAlign: 'center',
    marginBottom: 8,
  },
  aboutDescription: {
    fontSize: 14,
    color: '#6B7280',
    lineHeight: 22,
    textAlign: 'center',
  },
  aboutTeam: {
    alignItems: 'center',
    gap: 4,
  },
  aboutSubtitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1F2937',
    marginBottom: 8,
  },
  aboutTeamName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#3B82F6',
  },
  aboutFeatures: {
    gap: 4,
  },
  aboutFeatureItem: {
    fontSize: 14,
    color: '#6B7280',
    lineHeight: 20,
  },
  aboutFooter: {
    fontSize: 14,
    color: '#6B7280',
    textAlign: 'center',
    fontStyle: 'italic',
    marginTop: 8,
  },
});