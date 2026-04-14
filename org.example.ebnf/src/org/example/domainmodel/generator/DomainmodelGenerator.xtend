package org.example.domainmodel.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

import org.example.domainmodel.domainmodel.Language
import org.example.domainmodel.domainmodel.Rule
import org.example.domainmodel.domainmodel.Alternative
import org.example.domainmodel.domainmodel.Sequence
import org.example.domainmodel.domainmodel.Keyword
import org.example.domainmodel.domainmodel.RuleCall
import org.example.domainmodel.domainmodel.BuiltInTerminals
import org.example.domainmodel.domainmodel.Group
import org.example.domainmodel.domainmodel.Repetition

class DomainmodelGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val root = resource.allContents.filter(Language).head
		if (root !== null) {
			fsa.generateFile(root.name + ".xtext", root.generateGrammar)
		}
	}

	def generateGrammar(Language lang) '''
		grammar org.example.«lang.name.toLowerCase».«lang.name» with org.eclipse.xtext.common.Terminals

		generate «lang.name.toLowerCase» "http://www.example.org/«lang.name.toLowerCase»/«lang.name»"
		«var isFirstRule = true»
		«FOR rule : lang.rules»

			«IF rule instanceof Rule»
				«generateRule(rule as Rule, isFirstRule)»
				«{ isFirstRule = false; "" }»
			«ENDIF»
		«ENDFOR»
	'''

	def generateRule(Rule rule, boolean isFirst) '''
		«rule.name»:
			«IF isFirst»{«rule.name»}«ENDIF»
			«generateAlternative(rule.body as Alternative)»;
	'''

	// The remaining of the methods are on the same line so the generator doesn't
	// put them on multiple lines. It reduces readability, but improves the output.
	// I couldn't find any way to resolve this.

	// Alternatives
	def CharSequence generateAlternative(Alternative alt) '''«FOR seq : alt.sequences SEPARATOR ' | '»«generateSequence(seq)»«ENDFOR»'''

	def CharSequence generateAlternativeAsList(Alternative alt) '''«FOR seq : alt.sequences SEPARATOR ' | '»«generateSequenceAsList(seq)»«ENDFOR»'''

	// Sequences
	def CharSequence generateSequence(Sequence seq) '''«FOR prim : seq.singleItems SEPARATOR ' '»«generateElement(prim)»«ENDFOR»'''

	def CharSequence generateSequenceAsList(Sequence seq) '''«FOR prim : seq.singleItems SEPARATOR ' '»«generateElementAsList(prim)»«ENDFOR»'''

	// Elements
	def dispatch CharSequence generateElement(Keyword kw) '''«"'"»«kw.value»«"'"»'''

	def dispatch CharSequence generateElement(RuleCall rc) '''«rc.ref.name.toFirstLower»=«rc.ref.name»'''

	def dispatch CharSequence generateElement(Group grp) '''(«generateAlternative(grp.expression as Alternative)»)'''

	def dispatch CharSequence generateElement(Repetition rep) '''(«generateAlternativeAsList(rep.expression as Alternative)»)*'''

	def dispatch CharSequence generateElement(BuiltInTerminals bi) '''name=«bi.name»'''

	def dispatch CharSequence generateElementAsList(BuiltInTerminals bi) '''«bi.name.toLowerCase»s+=«bi.name»'''

	def dispatch CharSequence generateElementAsList(RuleCall rc) '''«rc.ref.name.toFirstLower»s+=«rc.ref.name»'''

	// Xtend will only parse if these are present.
	def dispatch CharSequence generateElement(Object obj) ''''''
	def dispatch CharSequence generateElementAsList(Object obj) ''''''
}
